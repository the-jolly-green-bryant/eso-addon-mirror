-- German Version (WinterQueensSurveyBanker)

local L = {}
	L.SI_BINDING_NAME_WQSB_Transfer = "Gegenstände einlagern/entnehmen"
	L.WinterQueensSurveyBanker_BankMsg = "[WQSB] Du hast  <<1[Keine Gegenstände/einen Gegenstand/$d Gegenstände]>> in der Bank. Besuche zum Entnehmen einen Bankier und starte WinterQueensSurveyBanker erneut."
	L.WinterQueensSurveyBanker_Transferring = "[WQSB] Entnehme Fundberichte/Schatzkarten, die hier zu finden sind: %s"
	L.WinterQueensSurveyBanker_Depositing = "[WQSB] Lagere Fundberichte/Schatzkarten ein, die nicht hier zu finden sind: %s"
	L.WinterQueensSurveyBanker_XoutofY = "[WQSB] %s %s von %s: %s"
	L.WinterQueensSurveyBanker_TransferFail = "[WQSB] Entnehmen fehlgeschlagen. Bitte versuche es erneut."
	L.WinterQueensSurveyBanker_NotEnoughSpace = "[WQSB] Dein Inventar und/oder deine Bank ist voll - automatisches Einlagern/Entnehmen wurde gestoppt."
	L.WinterQueensSurveyBanker_GoToBank = "[WQSB] Du hast <<1[nichts /einen Fundbericht oder eine Schatzkarte/$d Fundberichte oder Schatzkarten]>> in deiner Bank, <<1[das/der oder die/die]>> <<l:2>> gefunden werden <<1[kann/kann/können]>>."
	L.WinterQueensSurveyBanker_RemindMe = "Erinnere mich beim Zonenwechsel, falls ich Fundberichte/Schatzkarten in meiner Bank habe."
	L.WinterQueensSurveyBanker_AutoBank = "Verschiebe automatisch Fundberichte/Schatzkarten, sobald ich die Bank öffne."
	
for stringId, stringValue in pairs(L) do
	SafeAddString(_G[stringId], stringValue, 0)
end