--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: de.lua

  Copyright (c) 2018-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  Für weitere Informationen lies bitte die README Datei.
  ]]

--main
SafeAddString(SI_AWEVS_ALL_MODS_DISABLED, "Aktiviere ein Awesome_Events Modul", 1)
SafeAddString(SI_AWEVS_DESCRIPTION, "Bleib im Spielgeschehen mit Awesome Events! Erhalte Benachrichtigungen über relevante Ereignisse direkt während des Spielens. Tauche ein und entdecke verschiedene Module sowie Anpassungsmöglichkeiten, um dein Spielerlebnis zu optimieren. Vergiss nicht, alle Optionen auf der Einstellungsseite zu erkunden. Dein Feedback ist unverzichtbar! Wenn du Vorschläge, Übersetzungsbeiträge oder Fehlermeldungen hast, zögere nicht, dich zu melden. Du erreichst mich über die Add-On-Seite unter https://esoui.com.", 1)

--debug
SafeAddString(SI_AWEVS_DEBUG_NO_EVENT_CALLBACKS, "Keine Callbacks, EventListener entfernt!", 1)
SafeAddString(SI_AWEVS_DEBUG_ENABLED, "|c82D482AKTIVIERT", 1)
SafeAddString(SI_AWEVS_DEBUG_DISABLED, "|cD49682DEAKTIVIERT", 1)
SafeAddString(SI_AWEVS_DEBUG_MODULE_EVENT_INVALID, "Ungültiges event Objekt!\nErwartet: event={eventCode=EVENT_...,callback=function() ... end}!\nBeide Schlüssel werden benötigt!\nIst:", 1)
SafeAddString(SI_AWEVS_DEBUG_MODULE_OPTION_INVALID, "Ungültiges options Objekt!\nErwartet: option={type='',name='',tooltip='',default=...}!\nDiese Schlüssel werden mindestens benötigt!\nIst:", 1)
SafeAddString(SI_AWEVS_DEBUG_MODULE_NOT_FOUND, "Modul nicht gefunden!", 1)
SafeAddString(SI_AWEVS_DEBUG_MODULE_NO_TIMER, "Diese modul reagiert nicht auf das Event EVENT_TIMER oder du versuchst eine Timer Funktion innerhalb der Enable Funktion aufzurufen, sorry das geht leider nicht. Der timer kann nicht genutzt werden.", 1)
SafeAddString(SI_AWEVS_DEBUG_COMMAND_USAGE, "Befehl: /aedebug mod_id (on\off)", 1)

--appearance
SafeAddString(SI_AWEVS_APPEARANCE, "Darstellung", 1)
SafeAddString(SI_AWEVS_APPEARANCE_MOVABLE, "Fenster verschiebbar", 1)
SafeAddString(SI_AWEVS_APPEARANCE_MOVABLE_HINT, "Entsperrt das Fenster, sodass es frei mit der Maus verschoben werden kann.", 1)
SafeAddString(SI_AWEVS_APPEARANCE_TEXTALIGN, "Text-Ausrichtung", 1)
SafeAddString(SI_AWEVS_APPEARANCE_TEXTALIGN_HINT, "Verändere die Ausrichtung aller Benachrichtigungen.", 1)
SafeAddString(SI_AWEVS_APPEARANCE_TEXTALIGN_LEFT, "Linksbündig", 1)
SafeAddString(SI_AWEVS_APPEARANCE_TEXTALIGN_CENTER,"Zentriert", 1)
SafeAddString(SI_AWEVS_APPEARANCE_TEXTALIGN_RIGHT, "Rechtsbündig", 1)
SafeAddString(SI_AWEVS_APPEARANCE_UISCALE, "Fenster Größe / Skalierung", 1)
SafeAddString(SI_AWEVS_APPEARANCE_UISCALE_HINT, "Vergrößere oder verkleinere die Darstellung des Fensters.",1)
SafeAddString(SI_AWEVS_APPEARANCE_BACKGROUND_ALPHA, "Hintergrund-Transparenz", 1)
SafeAddString(SI_AWEVS_APPEARANCE_BACKGROUND_ALPHA_HINT, "Lege fest wie durchsichtig der Hintergrund ist.",1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_AVAILABLE,"Farbe von Verfügbarkeiten", 1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_AVAILABLE_HINT, "Ändere die Textfarbe von Verfügbarkeits-Meldungen.", 1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_HINT,"Farbe von Hinweisen", 1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_HINT_HINT, "Ändere die Textfarbe von Hinweis-Meldungen.", 1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_WARNING,"Farbe von Warnungen", 1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_WARNING_HINT, "Ändere die Textfarbe von Warnungen.", 1)
SafeAddString(SI_AWEVS_APPEARANCE_SHOWDISABLEDTEXT, "Hinweis: Kein Modul aktiviert", 1)
SafeAddString(SI_AWEVS_APPEARANCE_SHOWDISABLEDTEXT_HINT, "Zeige einen Hinweis im Awesome Events Fenster, wenn keine Module aktiviert sind.", 1)

--import
SafeAddString(SI_AWEVS_IMPORT,"Einstellungen Importieren", 1)
SafeAddString(SI_AWEVS_IMPORT_DESCRIPTION,"Übernehme die Einstellungen von einem anderen Charakter", 1)
SafeAddString(SI_AWEVS_IMPORT_CHARACTER_LABEL,"Importiere von", 1)
SafeAddString(SI_AWEVS_IMPORT_CHARACTER_SELECT," - Wähle einen Charakter -", 1)
SafeAddString(SI_AWEVS_IMPORT_BUTTON,"Importieren", 1)

--module-all
SafeAddString(SI_AWEMOD_SHOW, "Anzeigen", 1)
SafeAddString(SI_AWEMOD_SHOW_HINT, "Aktiviere oder deaktiviere alle Benachrichtigungen dieses Moduls", 1)
SafeAddString(SI_AWEMOD_SPACING_POSITION, "Abstand (Positionierung)", 1)
SafeAddString(SI_AWEMOD_SPACING_POSITION_HINT, "Wähle die Positionierung des Abstands zwischen Nachrichten dieses Moduls und anderen Benachrichtigungen.", 1)
SafeAddString(SI_AWEMOD_SPACING_BOTTOM, "Unten", 1)
SafeAddString(SI_AWEMOD_SPACING_BOTH, "Oben und Unten", 1)
SafeAddString(SI_AWEMOD_SPACING_TOP, "Oben", 1)
SafeAddString(SI_AWEMOD_SPACING, "Abstand (Größe)", 1)
SafeAddString(SI_AWEMOD_SPACING_HINT, "Wähle den Abstand zwischen Nachrichten dieses Moduls und anderen Benachrichtigungen.", 1)
SafeAddString(SI_AWEMOD_FONTSIZE, "Schriftgröße", 1)
SafeAddString(SI_AWEMOD_FONTSIZE_HINT, "Wähle die Schriftgrößer aller Benachrichtigungen diese Moduls.", 1)

--module-bufffood
SafeAddString(SI_AWEMOD_BUFFFOOD, "Versorgungs-Wirkzeit (Buff-Food)", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_HINT, "Erhalte eine Benachrichtigung mit verbleibender Zeit, wenn der Effekt deiner Nahrung kurz vor dem Ablauf steht oder du bereits neue Buff-Nahrung zu dir nehmen kannst.", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_TIMER_LABEL, "Effekt <<C:1>> endet in", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_READY_LABEL, "Keine Buff-Food Effekte aktiv!", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_TIMER, "Restzeit-Hinweis ab (Minuten)", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_TIMER_HINT, "Zeigt den Versorgungs-Hinweis mit Countdown an, sobald der Effekt der genommenen Nahrung in weniger als der hier festgelegten Minutenzahl auslaufen wird.", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_BLINKINCOMBAT, "Blinken (im Kampf)", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_BLINKINCOMBAT_HINT, "Die Warnung fängt an zu blinken, wenn du dich im Kampf befindest und keinen Buff-Food Effekt aktiv hast.", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_HIDENOCOMBAT, "Ausblenden (Ohne Kampf)", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_HIDENOCOMBAT_HINT, "Wenn du keinen Versorgungs-Effekt aktiv hast und 5 minuten lang an keinem Kampf teilnimmst, wird die Warnung bis zum nächsten Kampf oder bis zur nächsten Mahlzeit ausgeblendet.", 1)

--module-clock
SafeAddString(SI_AWEMOD_CLOCK, "Uhrzeit und Datum", 1)
SafeAddString(SI_AWEMOD_CLOCK_HINT, "Zeige die aktuelle Uhrzeit und das Datum auf dem Bildschirm an.", 1)
SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT, "Datumsformat", 1)
SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT_HINT, "Wähle die gewünschte Darstellung für die Datumsformatierung aus.", 1)
SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT_DAY, "tag", 1)
SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT_MONTH, "monat", 1)
SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT_YEAR, "jahr", 1)
SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT_DEFAULT, "day.month.year", 1)
SafeAddString(SI_AWEMOD_CLOCK_STYLE, "Darstellung", 1)
SafeAddString(SI_AWEMOD_CLOCK_STYLE_HINT, "Wähle deine bevorzugte Darstellung.", 1)
SafeAddString(SI_AWEMOD_CLOCK_STYLE_TIME, "Nur Uhrzeit", 1)
SafeAddString(SI_AWEMOD_CLOCK_STYLE_DATETIME_SHORT, "Datum & Uhrzeit (Einzeilig)", 1)
SafeAddString(SI_AWEMOD_CLOCK_STYLE_DATETIME_LONG, "Datum & Uhrzeit (Zweizeilig)", 1)
SafeAddString(SI_AWEMOD_CLOCK_FORMAT, "Uhrzeit 24-Stunden-Format", 1)
SafeAddString(SI_AWEMOD_CLOCK_FORMAT_HINT, "Schalte auf das 24-Stunden Format statt 12-Stunden (+AM/PM) Format um.", 1)

--module-crafting
SafeAddString(SI_AWEMOD_CRAFTING, "Handwerk", 1)
SafeAddString(SI_AWEMOD_CRAFTING_HINT, "Erhalte eine Benachrichtigung mit verbleinder Zeit, wenn deine laufende Analyse eines Handwerksberufs kurz vor dem Abschluss steht, oder ob du bereits eine neue Analyse starten kannst.", 1)
SafeAddString(SI_AWEMOD_CRAFTING_AVAILABLE_LABEL, "Analyse", 1)
SafeAddString(SI_AWEMOD_CRAFTING_BLACKSMITHING, "Schmiedekunst anzeigen", 1)
SafeAddString(SI_AWEMOD_CRAFTING_BLACKSMITHING_HINT, "Aktiviere die Anzeige in wie viel Minuten ein neuer Gegenstand in der Schmiede analysiert werden kann.", 1)
SafeAddString(SI_AWEMOD_CRAFTING_CLOTHING, "Schneiderei anzeigen", 1)
SafeAddString(SI_AWEMOD_CRAFTING_CLOTHING_HINT, "Aktiviere die Anzeige in wie viel Minuten ein neuer Gegenstand in der Schneiderbank analysiert werden kann.", 1)
SafeAddString(SI_AWEMOD_CRAFTING_JEWELRY, "Schmuckhandwerk anzeigen", 1)
SafeAddString(SI_AWEMOD_CRAFTING_JEWELRY_HINT, "Aktiviere die Anzeige in wie viel Minuten ein neuer Gegenstand am Schmuckhandwerkstisch analysiert werden kann.", 1)
SafeAddString(SI_AWEMOD_CRAFTING_WOODWORKING, "Schreinerei anzeigen", 1)
SafeAddString(SI_AWEMOD_CRAFTING_WOODWORKING_HINT, "Aktiviere die Anzeige in wie viel Minuten ein neuer Gegenstand in der Schreinerbank analysiert werden kann.", 1)
SafeAddString(SI_AWEMOD_CRAFTING_TIMER, "Analyse-Hinweis ab (Minuten)", 1)
SafeAddString(SI_AWEMOD_CRAFTING_TIMER_HINT, "Zeigt die oben gewählten Analyse-Hinweis mit Countdown an, sobald die Analyse in weniger als der hier festgelegten Minutenzahl abgeschlossen wird.", 1)

--module-durability
SafeAddString(SI_AWEMOD_DURABILITY, "Haltbarkeit getragener Rüstung", 1)
SafeAddString(SI_AWEMOD_DURABILITY_LABEL, "Rüstungszustand", 1)
SafeAddString(SI_AWEMOD_DURABILITY_HINT, "Erhalte eine Benarichtigung über die Haltbarkeit deiner getragenen Rüstung, bevor diese zu schwach wird.", 1)
SafeAddString(SI_AWEMOD_DURABILITY_INFO, "Haltbarkeit (|cFFFF60Hinweis|r) %", 1)
SafeAddString(SI_AWEMOD_DURABILITY_INFO_HINT, "Wenn die Haltbarkeit eines deiner Rüstungsteile höchstens den hier eingestellte Wert hat, wird ein Hinweis angezeigt.", 1)
SafeAddString(SI_AWEMOD_DURABILITY_WARNING, "Haltbarkeit (|cFF6060Warnung|r) %", 1)
SafeAddString(SI_AWEMOD_DURABILITY_WARNING_HINT, "Wenn die Haltbarkeit eines deiner Rüstungsteile höchstens den hier eingestellte Wert hat, wird eine Warnung angezeigt.", 1)

--module-fencing
SafeAddString(SI_AWEMOD_FENCING, "Diebesgilde", 1)
SafeAddString(SI_AWEMOD_FENCING_HINT, "Erhalte eine Benarichtigung über die verbleibenden Transaktionen bei deinem Hehler, sobald diese unter die unten eingestellten Werte sinken, oder erhalte einen Countdown, wann du neue Transaktionen tätigen kannst.", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_LABEL, "Hehlerei", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_LABEL, "Schieben", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS, "Verbleibende Verkäufe anzeigen", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_HINT, "Aktiviere Hinweise über die verbleibenden Verkäufe von Diebesgut, sobald diese unter die folgenden Werte fallen.", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_INFO, "Verkäufe (|cFFFF60Hinweis|r)", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_INFO_HINT,"Wenn du nur noch die hier eingestellte Anzahl an Diebesgut an den Hehler verkaufen kannst, wird ein Hinweis angezeigt.", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_WARNING, "Verkäufe (|cFF6060Warnung|r)", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_WARNING_HINT,"Wenn du nur noch die hier eingestellte Anzahl an Diebesgut an den Hehler verkaufen kannst, wird eine Warnung angezeigt.", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS, "Verbleibendes Schieben anzeigen", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_HINT, "Aktiviere Hinweise über die verbleibenden Schiebe-Vorgänge von Diebesgut, sobald diese unter die folgenden Werte fallen.", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_INFO,"Schieben/Reinwaschen (|cFFFF60Hinweis|r)", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_INFO_HINT,"Wenn du nur noch die hier eingestellte Anzahl an Diebesgut rein waschen kannst, wird ein Hinweis angezeigt.", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_WARNING,"Schieben/Reinwaschen (|cFF6060Warnung|r)", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_WARNING_HINT,"Wenn du nur noch die hier eingestellte Anzahl an Diebesgut rein waschen kannst, wird eine Warnung angezeigt.", 1)

--module-inventory
SafeAddString(SI_AWEMOD_INVENTORY, "Inventar (Platz & Geld)", 1)
SafeAddString(SI_AWEMOD_INVENTORY_HINT, "Lass dir deine Inventarauslatung anzeigen, dein aktuelles Vermögen und/oder erhalte eine Benachrichtigung, bevor dir der Inventarplatz ausgeht.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW, "Verbleibende freie Plätze anzeigen", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_HINT, "Erhalte eine Benachrichtigung, bevor dir der Platz im Rucksack ausgeht.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_INFO, "Freie Plätze (|cFFFF60Hinweis|r)", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_INFO_HINT, "Wenn nur noch die hier eingestellte Anzahl an Plätzen in deinem Rucksack unbelegt ist, wird ein Hinweis angezeigt.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_WARNING, "Freie Plätze (|cFF6060Warnung|r)", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_WARNING_HINT,"Wenn nur noch die hier eingestellte Anzahl an Plätzen in deinem Rucksack unbelegt ist, wird eine Warnung angezeigt.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_LABEL, "Rucksackplatz|r: <<1>>", 1)
SafeAddString(SI_AWEMOD_INVENTORY_DETAILS, "Inventarauslastung anzeigen", 1)
SafeAddString(SI_AWEMOD_INVENTORY_DETAILS_HINT, "Lasse dir die aktuelle Bank- und Rucksackauslastung anzeigen.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_DETAILS_LABEL, "<<1>>Rucksack|r: <<2>>/<<3>> <<1>>|| Bank|r: <<4>>/<<5>>", 1)
SafeAddString(SI_AWEMOD_INVENTORY_MONEY, "Vermögen (Gold) anzeigen", 1)
SafeAddString(SI_AWEMOD_INVENTORY_MONEY_HINT, "Lasse dir dein eingelagertes und verfügbares Vermögen anzeigen.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_MONEY_LABEL, "Gold|r: <<1>>k |t16:16:EsoUI/Art/currency/currency_gold.dds|t<<2[/ (+1k eingelagert)/ (+$dk eingelagert)]>>", 1)
SafeAddString(SI_AWEMOD_INVENTORY_ADVCURRENCIES, "Währungen (andere) anzeigen", 1)
SafeAddString(SI_AWEMOD_INVENTORY_ADVCURRENCIES_HINT, "Lasse dir deine Anzahl an Telvar Steinen und Schriebscheinen anzeigen.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_TELVARSTONES_LABEL, "Telvar|r: <<1>> |t16:16:EsoUI/Art/currency/currency_telvar.dds|t", 1)
SafeAddString(SI_AWEMOD_INVENTORY_WRITVOUCHER_LABEL, "Scheine:|r <<1>> |t16:16:EsoUI/Art/currency/currency_writvoucher.dds|t", 1)

--module-mails
SafeAddString(SI_AWEMOD_MAILS, "Nachrichten", 1)
SafeAddString(SI_AWEMOD_MAILS_HINT, "Erhalte eine Benachrichtigung, sobald du ungelesene Nachrichten im Posteingang hast.", 1)
SafeAddString(SI_AWEMOD_MAILS_LABEL, "Neue Nachrichten", 1)

--module-mount
SafeAddString(SI_AWEMOD_MOUNT, "Reittier Training", 1)
SafeAddString(SI_AWEMOD_MOUNT_HINT, "Erhalte eine Benachrichtigung mit verbleibender Zeit, wenn das Training von deinem Reittier kurz vor dem Abschluss steht, oder du bereits ein neues Training starten kannst.", 1)
SafeAddString(SI_AWEMOD_MOUNT_TIMER_LABEL, "Reittier trainiert", 1)
SafeAddString(SI_AWEMOD_MOUNT_READY_LABEL, "Reittier kann trainieren", 1)
SafeAddString(SI_AWEMOD_MOUNT_TIMER, "Trainigs-Hinweis ab (Minuten)", 1)
SafeAddString(SI_AWEMOD_MOUNT_TIMER_HINT, "Zeigt den Trainings-Hinweis mit Countdown an, sobald das laufende Training in weniger als der hier festgelegten Minutenzahl abgeschlossen wird.", 1)

--module-repairkits
SafeAddString(SI_AWEMOD_REPAIRKITS, "Reparatur-Kits", 1)
SafeAddString(SI_AWEMOD_REPAIRKITS_HINT, "Lass dir anzeigen, wie viele Reparatur-Kisten du im Rucksack hast.", 1)
SafeAddString(SI_AWEMOD_REPAIRKITS_LABEL, "Reparatur-Kits|r: |t16:16:EsoUI/Art/icons/store_repairkit_002.dds|t <<1[Keine/1 Kiste/$d Kisten]>>", 1)

--module-shadowysupplier
SafeAddString(SI_AWEMOD_SHADOWYSUPPLIER, "Verhüllter Versorger (Passive Fähigkeit)", 1)
SafeAddString(SI_AWEMOD_SHADOWYSUPPLIER_HINT, "Der verhüllte Versorger ist eine passive Fähigkeit aus der Fertigkeitslinie der dunklen Bruderschaft. Erhalte eine Benachrichtigung mit verbleibender Zeit, wann der nächste verhüllte Versorger zur Verfügung steht, oder ob er bereits auf dich wartet.", 1)
SafeAddString(SI_AWEMOD_SHADOWYSUPPLIER_TIMER, "Wartezeit-Hinweis ab (Minuten)", 1)
SafeAddString(SI_AWEMOD_SHADOWYSUPPLIER_TIMER_HINT, "Zeigt den Verhüllter-Versorger-Hinweis mit Countdown an, sobald der verhüllte Versorger in weniger als der hier festgelegten Minutenzahl wieder verfügbar ist.", 1)
SafeAddString(SI_AWEMOD_SHADOWYSUPPLIER_AVAILABLE_LABEL, "Verfügbar", 1)

--module-skills
SafeAddString(SI_AWEMOD_SKILLS, "Attribute- und Fertigkeiten", 1)
SafeAddString(SI_AWEMOD_SKILLS_HINT, "Erhalte eine Benachrichtigung, sobald du über nicht gesetzte Attributs- und Fertigkeitspunkte verfügst.", 1)
SafeAddString(SI_AWEMOD_SKILLS_ATTRIBUTES_LABEL, "Attribute", 1)
SafeAddString(SI_AWEMOD_SKILLS_CHAMPIONPOINTS_LABEL, "CP", 1)
SafeAddString(SI_AWEMOD_SKILLS_SKILLS_LABEL, "Skills", 1)

--module-skyshards
SafeAddString(SI_AWEMOD_SKYSHARDS, "Himmelsscherben", 1)
SafeAddString(SI_AWEMOD_SKYSHARDS_HINT, "Er halte eine Benarichtigung darüber, wie viele Himmelsscherben dir noch zum nächsten Fertigkeitspunkt fehlen.", 1)
SafeAddString(SI_AWEMOD_SKYSHARDS_REMAINING_LABEL, "Scherben", 1)
SafeAddString(SI_AWEMOD_SKYSHARDS_REMAINING, "Scherben-Hinweis ab (fehlend)", 1)
SafeAddString(SI_AWEMOD_SKYSHARDS_REMAINING_HINT, "Wenn du nur noch die hier eingestellte Anzahl an Himmelsscherben für einen Fertigkeitspunkt benötigst, wird ein Hinweis angezeigt.", 1)

--module-soulgems
SafeAddString(SI_AWEMOD_SOULGEMS, "Seelensteine (Wiederbelebung)", 1)
SafeAddString(SI_AWEMOD_SOULGEMS_HINT, "Lass dir anzeigen, wie viele leere oder gefüllte Seelensteine du für deine eigene Wiederbelebung hast.", 1)
SafeAddString(SI_AWEMOD_SOULGEMS_LABEL, "Seelensteine|r: <<1>> |t16:16:EsoUI/Art/icons/soulgem_006_filled.dds|t <<2[/(1 leerer)/($d leere)]>>", 1)

--module-weaponchrage
SafeAddString(SI_AWEMOD_WEAPONCHARGE, "Aufladung ausgerüsteter Waffen", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_HINT, "Erhalte eine Benarichtigung über die verbleinden Aufladungen deiner ausgerüsteten Waffen, bevor diese leer geht.", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_INFO, "Aufladung (|cFFFF60Hinweis|r) %", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_INFO_HINT, "Wenn die Aufladung deiner Waffen-Verzauberung höchstens den hier eingestellte Wert hat, wird ein Hinweis angezeigt.", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_WARNING, "Aufladung (|cFF6060Warnung|r) %", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_WARNING_HINT, "Wenn die Aufladung deiner Waffen-Verzauberung höchstens den hier eingestellte Wert hat, wird eine Warnung angezeigt.", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_SET_LABEL, "Set", 1)