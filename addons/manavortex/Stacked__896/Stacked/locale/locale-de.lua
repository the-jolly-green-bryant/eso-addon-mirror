local L = _G['Stacked'].L

L['Stack'] = 'Stapeln' -- keybind

-- --------------------------------------------------------
-- settings
L['General Options'] = 'Allgemeine Einstellungen'
L['merge target'] = 'Stapel kombinieren'
L['merge target description'] = 'Wenn ein Gegenstand in mehreren Taschen unvollständige Stapel hat, können diese in eine Tasche kombiniert werden.'
L['merge guildbank target'] = 'Stapel kombinieren (Gildenbank)'
L['merge guildbank target description'] = L['merge target description']
L['none'] = 'Keine'
L['backpack'] = 'Rucksack'
L['bank'] = 'Bank'
L['guildbank'] = 'Gildenbank'

L['tradeSucceeded'] = GetString(SI_TRADE_COMPLETE):gsub('%.$', '')
L['attachmentsRetrieved'] = 'Briefanhänge entnommen'
L['bank opened'] = 'Bank geöffnet'
L['guildbank opened'] = 'Gildenbank geöffnet'

L['ignore items'] = 'Gegenstände ignorieren'
L['ignore items description'] = 'Gegenstände auf deiner Ignorieren-Liste werden nicht von Stacked betrachtet.'
L['ignore items info'] = 'Nutze "|cFFFFFF/stacked list|r" um eine klickbare Liste aller ignorierten Gegenstände auszugeben. So kannst du leicht deren Namen herausfinden!'
L['ignore items help'] = 'Eine Zeile pro Gegenstand mit entweder der Gegenstands-ID oder dem Link (nutze die Option "|cFFFFFF'..GetString(SI_ITEM_ACTION_LINK_TO_CHAT)..'|r" und kopiere den Chat-Link in dieses Textfeld).'

L['ignore item'] = 'Nicht stapeln'
L['unignore item'] = 'Stapeln erlauben'

L['Messages'] = 'Nachrichten'
L['item moved'] = 'Gegenstand wurde bewegt'
L['item moved description'] = 'Zeige eine Chat-Nachricht wenn ein Gegenstand bewegt wurde.'
L['slots'] = 'Nummer des Taschenplatzes'
L['slots description'] = 'Zeige die Nummer des Taschenplatzes in allen Nachrichten.'
L['guild bank details'] = 'Details für Gildenbank-Aktionen'
L['guild bank details description'] = 'Zeige alle einzelnen Aktionen beim Gildenbank-Stapeln, insbesondere getätigte Entnahmen und Einzahlungen.'

L['Automatic Stacking'] = 'Automatisch Stapeln'
L['automatic events'] = 'Bei diesen Ereignissen automatisch stapeln:'
L['automatic containers'] = 'Nur diese Taschen automatisch bearbeiten:'

-- --------------------------------------------------------
-- slash commands
L['/help'] = '<<1>> Befehlshilfe: <<2>>'
L['/stack'] = '"|cFFFFFF/stack|r" um das Stapeln auszulösen'
L['/stackgb'] = '"|cFFFFFF/stackgb|r" um die Gildenbank zu stapeln'
L['/stacked list'] = '"|cFFFFFF/stacked list|r" um ignorierte Gegenstände aufzulisten'
L['/stacked exclude'] = '"|cFFFFFF/stacked exclude|r |cFF80401234|r" um den Gegenstand mit ID 1234 zu ignorieren'
	.. '\n"|cFFFFFF/stacked exclude|r |cFF8040[Item Link]|r" um den verlinkten Gegenstand zu ignorieren'
L['/stacked include'] = '"|cFFFFFF/stacked include|r |cFF80401234|r" um den Gegenstand mit ID 1234 nicht mehr zu ignorieren'
	.. '\n"|cFFFFFF/stacked include|r |cFF8040[Item Link]|r" um den verlinkten Gegenstand nicht mehr zu ignorieren'

-- --------------------------------------------------------
-- container stacking
L['bag slot number'] = '<<1>> (Platz <<2>>)'
L['stacked item'] = '<<2*1>> (<<and(4,5)>>) <<2[wurde/wurden]>> in <<3>> gestapelt.' -- <<3{den $s/der $s/dem $s}>>
L['failed stacking item'] = 'Stapeln von <<2*1>> in <<3>> ist fehlgeschlagen.'
L['moved item'] = '<<2*1>> <<2[wurde/wurden]>> von <<3>> nach <<4>> bewegt.'
L['failed moving item'] = 'Bewegen von <<2*1>> in <<3>> nach <<4>> ist fehlgeschlagen.'
L['stacking completed'] = 'Stapeln abgeschlossen.'

-- --------------------------------------------------------
-- guild bank stacking
L['failed moving guildbank item'] = 'Bewegen von Gegenstand zwischen Tasche und Gildenbank ist fehlgeschlagen: <<1>>.'
L['stacking guildbank item'] = 'Stapeln von <<2*1>>, verteilt auf <<03*Platz^m||Plätze^p>>'
L['failed stacking guildbank item'] = 'Stapeln von <<1>> ist fehlgeschlagen: <<2>>.'
L['withdraw item'] = '<<2*1>> entnehmen'
L['deposit item'] = '<<2*1>> einzahlen'
L['guild bank state 0'] = 'Gildenbank-Stapeln abgeschlossen. <<01*Platz^m||Plätze^p>> gewonnen.'
L['guild bank state 2'] = 'Bewege Gegenstände von <<1>> nach <<2>>.'
L['guild bank state 3'] = 'Stapeln der Gegenstände der Gildenbank gestartet.'

-- error messages
L['not enough members'] = 'Diese Gilde hat nicht genügend Mitglieder um die Gildenbank zu nutzen.'
L['insufficient permissions'] = 'Du benötigst sowohl Einzahlungs- als auch Entnahme-Berechtigungen um die Gildenbank zu stapeln.'
L['inventory full'] = 'Es werden mindestens 2 freie Taschenplätze zum Stapeln der Gildenbank benötigt.'
L['not available'] = 'Gildenbank-Daten sind noch nicht verfügbar.'

