-- English Version (WinterQueensSurveyBanker)
local L = {}
	L.SI_BINDING_NAME_WQSB_Transfer = "Transfer items"
	L.WinterQueensSurveyBanker_BankMsg = "[WQSB] You have  <<1[no items/one item/$d items]>> in your bank that could be sent. Visit a banker and run WinterQueensSurveyBanker again to transfer them to your inventory."
	L.WinterQueensSurveyBanker_Transferring = "[WQSB] Taking surveys/treasure maps for %s from bank..."
	L.WinterQueensSurveyBanker_Depositing = "[WQSB] Depositing surveys/treasure maps not for %s..."
	L.WinterQueensSurveyBanker_XoutofY = "[WQSB] %s %s out of %s: %s"
	L.WinterQueensSurveyBanker_TransferFail = "[WQSB] Failed to transfer item - please try again."
	L.WinterQueensSurveyBanker_NotEnoughSpace = "[WQSB] Your inventory and/or bank is full. Auto-transfer stopped."
	L.WinterQueensSurveyBanker_GoToBank = "[WQSB] You have <<1[nothing /one survey or treasure map/$d surveys or treasure maps]>> in your bank that can be found <<l:2>>."
	L.WinterQueensSurveyBanker_RemindMe = "Remind me on zone-change if I have surveys in my bank."
	L.WinterQueensSurveyBanker_AutoBank = "Auto-transfer surveys when I open the bank."
	
for stringId, stringValue in pairs(L) do
	ZO_CreateStringId(stringId, stringValue)
end