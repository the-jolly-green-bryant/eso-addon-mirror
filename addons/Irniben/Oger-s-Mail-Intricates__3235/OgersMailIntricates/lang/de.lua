-- German Version (Oger's Mail Intricates)

local L = {}

	L.OgersMailIntricates_NoArgs = "[OMI] Bitte nutze folgende Syntax:\n/oaa @playername 0\nDabei steht '0' für 'alles versenden' und kann durch eine der folgenden Zahlen ersetzt werden: 1) Schneiderei, 2) Schmiedekunst, 3) Schreinerei und 4) Schmuckhandwerk."
	
	L.OgersMailIntricates_NoRecipient = "[OMI] Kein Empfänger ausgewählt"
	L.OgersMailIntricates_MailSuccess = "[OMI] Nachricht erfolgreich an |H0:character:%s|h%s|h gesendet."
	L.OgersMailIntricates_MailFail = "[OMI] Nachricht konnte nicht gesendet werden - "
	L.OgersMailIntricates_InCombat = "[OMI] Du kannst im Kampf keine Nachrichten versenden."
	L.OgersMailIntricates_Sending = "[OMI] Verschicke an |H0:character:%s|h%s|h: %s"
	L.OgersMailSpecialFail = "[OMI] Es scheint Probleme mit Nachrichten zu geben, die immer noch in der Warteschleife hängen. Bitte prüfe dein Inventar und versuche es ggf. erneut."
	L.OgersMailIntricates_BankMsg = "[OMI] Du hast  <<1[Keine Gegenstände/einen Gegenstand/$d Gegenstände]>> in der Bank. Besuche zum Entnehmen einen Bankier und starte OgersMailIntricates erneut."
	L.OgersMailIntricates_Transferring = "[OMI] Entnehme Gegenstände aus der Bank..."
	L.OgersMailIntricates_XoutofY = "[OMI] %s von %s: %s"
	L.OgersMailIntricates_NotEnoughSpace = "[OMI] Nicht genug Platz im Inventar."
	L.OgersMailIntricates_TransferFail = "[OMI] Entnehmen fehlgeschlagen. Bitte versuche es erneut."
	L.OgersMailIntricates_InventoryFull = "[OMI] Dein Inventar ist voll - automatisches Entnehmen wurde gestoppt."
	L.OgersMailIntricates_Context = "Kontextmenü in Chat und Gildenliste"
	
	L.OgersMailIntricates_MenuSend = "Intrikate versenden"

for stringId, stringValue in pairs(L) do
	SafeAddString(_G[stringId], stringValue, 0)
end