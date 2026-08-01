-- English Version (Oger's Mail Intricates)
local L = {}

	L.OgersMailIntricates_NoRecipient = "[OMI] Please choose a recipient first (via options)."
	L.OgersMailIntricates_NoArgs = "[OMI] Please use the following syntax:\n/oaa @playername 0\nWhere '0' will send all intricates and can be replaced by 1-4 for 1) clothing, 2) smithing, 3) woodworking and 4) jewelry."
	
	L.OgersMailIntricates_MailSuccess = "[OMI] Mail sent successfully to |H0:character:%s|h%s|h"
	L.OgersMailIntricates_MailFail = "[OMI] failed to send mail - "
	L.OgersMailIntricates_InCombat = "[OMI] You can't send mails while in combat."
	
	L.OgersMailIntricates_MenuSend = "Send intricates"
		
	L.OgersMailIntricates_Sending = "[OMI] Sending to |H0:character:%s|h%s|h: %s"
	L.OgersMailSpecialFail = "[OMI] There seems to be a problem with one or more mails still in the queue - please check your inventory and try again if necassary."
	
	L.OgersMailIntricates_BankMsg = "[OMI] You have  <<1[no items/one item/$d items]>> in your bank that could be sent. Visit a banker and run OgersMailIntricates again to transfer them to your inventory."
	L.OgersMailIntricates_Transferring = "[OMI] Taking items from bank..."
	L.OgersMailIntricates_XoutofY = "[OMI] %s out of %s: %s"
	L.OgersMailIntricates_NotEnoughSpace = "[OMI] Inventory is full."
	L.OgersMailIntricates_TransferFail = "[OMI] Failed to transfer item - please try again."
	L.OgersMailIntricates_InventoryFull = "[OMI] Your inventory is full. Auto-looting stopped."
	L.OgersMailIntricates_Context = "Add context menu to chat and guild roster"
	
for stringId, stringValue in pairs(L) do
	ZO_CreateStringId(stringId, stringValue)
end