-- Translated by: @ninibini

local Register = function(id, text) SafeAddString(_G[id], text, 1) end

Register("SI_ADVSET_PREAMBLE"      , "Änderungen, die an diesen Einstellungen gemacht werden, bleiben auf diesem Rechner gespeichert (in UserSettings.txt) auch wenn das Addon Advanced Game Settings deaktiviert oder deinstalliert wird.\n\nDie Einstellungen können auch über den Chat Befehl |c00CCFF/advset|r aufgerufen werden.")
Register("SI_ADVSET_FRAMECAP"      , "Maximale Bildfrequenz festlegen")
Register("SI_ADVSET_FRAMECAP_TT"   , "Die Bildfrequenz ist nicht beschränkt, wenn kein Maximalwert gesetzt ist. Diese Beschränkung wird auch auf den Login und Charakter Auswahlscreen angewendet.\n\nHinweis: Änderungen an der Bildfrequenz werden erst mit Ausloggen in die Charakter Auswahl übernommen.\n\nDefault: Aus")
Register("SI_ADVSET_SKIPLOGOS"     , "Logos während des Spielstarts überspringen")
Register("SI_ADVSET_SKIPLOGOS_TT"  , "Beim Spielstart wird direkt der Login Screen angezeigt.\n\nDefault: Aus")
Register("SI_ADVSET_SUSTAIN"       , "Nachhaltigkeit")
Register("SI_ADVSET_DETAILMAP"     , "Detaillierte Texturen deaktivieren")
Register("SI_ADVSET_DETAILMAP_TT"  , "Einige Spieler finden Felms' „Zorn manifestieren“ besser erkennbar wenn die detaillierten Texturen deaktiviert sind.\n\nDefault: Aus")
--Register("SI_ADVSET_LANGUAGE"      , GetString("SI_GUILDMETADATAATTRIBUTE", GUILD_META_DATA_ATTRIBUTE_LANGUAGES))
Register("SI_ADVSET_LANGUAGE_TT"   , "Dies ändert die Sprache des Spiels.\n\nHinweis: Markierte Sprachen (*) sind normalerweise nicht verfügbar. Sie werden für die meisten Installationen nicht funktionieren.")
Register("SI_ADVSET_LANGUAGE_WARN" , "Beim Ändern der Sprache wird die UI neu geladen.")
