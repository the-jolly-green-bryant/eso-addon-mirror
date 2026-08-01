-- German Version (MailBackPlease)

local L = {}

	L.SI_BINDING_NAME_MAILBACKPLEASE = "Versende 6 Gegenstände..."
	
	-- General UI
	L.MAILBACKPLEASE_Recipient = "Wähle einen Empfänger (Freundesliste)"
	L.MAILBACKPLEASE_Recipient_TT = "Alle MBP-Nachrichten werden an diesen Empfänger gesendet."
	L.MAILBACKPLEASE_Shakespeare = "Zufälliges Shakespeare-Zitat"
	L.MAILBACKPLEASE_Shakespeare_TT = "Fülle die Nachricht mit einem zufälligen Shakespeare-Zitat."
	L.MAILBACKPLEASE_OptionList = "Liste versendeter Gegenstände im Chat posten."	
	L.MAILBACKPLEASE_OptionAuto = "Automatisch weitere Nachrichten versenden."	
	L.MAILBACKPLEASE_MasterWrit = "Meisterschriebe"
	L.MAILBACKPLEASE_Motifs = "Stilseiten"
	L.MAILBACKPLEASE_Recipes = "Rezepte"
	L.MAILBACKPLEASE_FurniturePlans = "Einrichtungspläne"
	L.MAILBACKPLEASE_SimpleEquipment = "Einfache Ausrüstung (keine Setteile, maximal blaue Qualität)"
	L.MAILBACKPLEASE_Glyphs = "Glpyhen"
	L.MAILBACKPLEASE_NoRecipient = "[MBP]: Bitte wähle einen Empfänger in den Addon-Einstellungen."
	L.MAILBACKPLEASE_ItemNumberSent = "[MBP] An %s zu versendende Gegenstände: %s"
	L.MAILBACKPLEASE_AlertHead = "Warnung vor ablaufenden Mails (beim Einloggen)"
	L.MAILBACKPLEASE_AlertNumber = "Anzahl der Tage vor Ablauf"
	L.MAILBACKPLEASE_AlertNumberTooltip = "Wieviele Tage vor Ablauf einer Nachricht möchtest du erinnert werden?"
	L.MAILBACKPLEASE_AlertOnScreen = "Warnung in der Bildschirmmitte anzeigen"
	L.MAILBACKPLEASE_AlertInChat = "Warnung im Chat anzeigen"
	L.MAILBACKPLEASE_AlertTxtHead = "Du hast ablaufende Nachrichten!"
	L.MAILBACKPLEASE_AlertPlayer = "Eine deiner Spielernachrichten läuft in |ced0000<<1[-/einem Tag/$d Tagen]>>|r ab."
	L.MAILBACKPLEASE_AlertSystem = "Eine deiner Systemnachrichten läuft in |ced0000<<1[-/einem Tag/$d Tagen]>>|r ab."
	L.MAILBACKPLEASE_Subject = "Betreff"
	L.MAILBACKPLEASE_MailSpecialFail = " [MBP] Es scheint Probleme mit Nachrichten zu geben, die immer noch in der Warteschleife hängen. Bitte prüfe dein Inventar und versuche es ggf. erneut."
	L.MAILBACKPLEASE_MailFail = " [MBP] Nachricht konnte nicht gesendet werden - "
	L.MAILBACKPLEASE_MailSuccess = " [MBP] Nachricht erfolgreich an |H0:character:%s|h%s|h gesendet."
	
for stringId, stringValue in pairs(L) do
	SafeAddString(_G[stringId], stringValue, 0)
end