-- German Version (Caro's Collection Mail Group)

local L = {}

	L.SI_BINDING_NAME_CCMG = "Versende 6 Gegenstände..."
	
	-- General UI
	L.CCMG_Recipient = "Wähle einen Empfänger"
	L.CCMG_Reset = "Verlauf zurücksetzen"
	L.CCMG_Reset_Tooltip = "Setze die Liste der Gegenstände zurück, die bereits einmal die Runde gemacht haben und ignoriert werden."
	L.CCMG_AutoRead = "Post automatisch lesen"
	L.CCMG_AutoLoot = "Anhänge automatisch entnehmen"
	L.CCMG_SendAll = "Mehrere Nachrichten auf einmal versenden"
	L.CCMG_InboxHandler = "Eingehende Nachrichten"
	L.CCMG_PauseInDungeons = "In Verliesen und Prüfungen deaktivieren"
	L.CCMG_OnlyOnChar = "Nur auf bestimmtem Charakter"
	L.CCMG_AllChars = "--- Alle Charaktere ---"
	L.CCMG_DiagReset = "Möchtest du die Listen für die Collection-Mail-Group zurücksetzen? Dieser Schritt lässt sich nicht rückgängig machen."
	L.CCMG_DiagReset2 = "Möchtest du die Listen für den Direktversand zurücksetzen? Dieser Schritt lässt sich nicht rückgängig machen."
	L.CCMG_Resetted = "[CCMG] Listen zurückgesetzt."
	
	L.CCMG_MailSpecialFail = "[CCMG] Es scheint Probleme mit Nachrichten zu geben, die immer noch in der Warteschleife hängen. Bitte prüfe dein Inventar und versuche es ggf. erneut."
	L.CCMG_NoRecipient = "[CCMG] Kein Empfänger ausgewählt"
	L.CCMG_MailSuccess = "[CCMG] Nachricht erfolgreich an |H0:character:%s|h%s|h gesendet."
	L.CCMG_MailFail = "[CCMG] Nachricht konnte nicht gesendet werden - "
	L.CCMG_InCombat = "[CCMG] Du kannst im Kampf keine Nachrichten versenden."
	L.CCMG_BindingItems = "[CCMG] Gegenstände werden gebunden."
	L.CCMG_FinishedLooting = "[CCMG] Alle Anhänge erfolgreich entnommen. Nachricht(en) von: %s"
	L.CCMG_Ignore = "[CCMG] Ignoriere: "
	L.CCMG_SentItems = "[CCMG] Verschickte Gegenstände: "
	L.CCMG_IgnoredItems = "[CCMG] Ignorierte Gegenstände: "
	L.CCMG_NoTransfer = "[CCMG] Keine passenden Gegenstände in der Bank."
	L.CCMG_BankMsg = "[CCMG] Du hast  <<1[Keine Gegenstände/einen Gegenstand/$d Gegenstände]>> in der Bank. Besuche zum Entnehmen einen Bankier und starte CCMG erneut."
	L.CCMG_Transferring = "[CCMG] Entnehme Gegenstände aus der Bank..."
	L.CCMG_XoutofY = "[CCMG] %s von %s: %s"
	L.CCMG_NotEnoughSpace = "[CCMG] Nicht genug Platz im Inventar."
	L.CCMG_TransferFail = "[CCMG] Entnehmen fehlgeschlagen. Bitte versuche es erneut."
	L.CCMG_InventoryFull = "[CCMG] Dein Inventar ist voll - automatisches Entnehmen wurde gestoppt."
	L.CCMG_NothingToSend = "[CCMG] Keine passenden Gegenstände im Inventar."	
		
	L.CCMG_Context = "Kontextmenü im Chat"
	L.CCMG_ContextGuild = "Kontextmenü in der Gildenliste"
	L.CCMG_ContextSet = "[CCMG] Als Empfänger setzen"
	L.CCMG_ContextSetSend = "[CCMG] Setgegenstände verschicken (ohne Gruppe)..."
	L.CCMG_SendDirectly = "CCMG - Direktversand"
	L.CCMG_SendDirectlyIsRecipient = "Du hast ausgewählt, Gegenstände direkt an %s zu verschicken. Dieser Spieler ist auch der Standardempfänger in deiner Collection-Mail-Group. Beim Direktversand werden die Gegenstände nicht als 'gesendet' in der Gruppe markiert. Möchtest du sie dennoch direkt versenden?"
	L.CCMG_SendDirectlyNoLMAS = "LibMultiAccountSets wurde nicht gefunden oder enthält keine Daten für <<1>>. CCMG wird sich trotzdem merken, welche Gegenstände bereits an <<1>> verschickt wurden, kann aber nicht auf LMAS-Daten zurückgreifen. Dennoch versenden?"
	L.CCMG_NewRecipient = "[CCMG] |H0:character:%s|h%s|h wurde als Empfänger gesetzt."

for stringId, stringValue in pairs(L) do
	SafeAddString(_G[stringId], stringValue, 0)
end