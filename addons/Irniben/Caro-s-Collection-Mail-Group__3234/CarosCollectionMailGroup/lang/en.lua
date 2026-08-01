-- English Version (Caro's Collection Mail Group)
local L = {}

	L.SI_BINDING_NAME_CCMG = "Send 6 items..."
	
	-- General UI
	L.CCMG_Recipient = "Choose a recipient to send the items to..."
	L.CCMG_NoRecipient = "[CCMG] Please choose a recipient first (via options)."
	L.CCMG_Reset = "Reset history"
	L.CCMG_Reset_Tooltip = "Reset the list of items that have been sent by and returned to you and are therefore ignored."
	L.CCMG_AutoRead = "Check for incoming CCMG mails"
	L.CCMG_AutoLoot = "Auto-loot incoming CCMG mails"
	L.CCMG_SendAll = "Send multiple messages at once"
	L.CCMG_InboxHandler = "Inbox"
	L.CCMG_PauseInDungeons = "Pause while in dungeons/trials"
	L.CCMG_OnlyOnChar = "Only on one specific char"
	L.CCMG_AllChars = "--- Auto-read on all chars ---"
	L.CCMG_DiagReset = "Do you want to reset both lists for the mail group? This can't be undone."
	L.CCMG_DiagReset2 = "Do you want to reset all lists for items sent directly to players? This can't be undone."	
	L.CCMG_Resetted = "[CCMG] Resetted lists."
	
	L.CCMG_MailSpecialFail = "[CCMG] There seems to be a problem with one or more mails still in the queue - please check your inventory and try again if necassary."
	L.CCMG_MailSuccess = "[CCMG] Mail sent successfully to |H0:character:%s|h%s|h"
	L.CCMG_MailFail = "[CCMG] failed to send mail - "
	L.CCMG_InCombat = "[CCMG] You can't send mails while in combat."
	L.CCMG_BindingItems = "[CCMG] Trying to bind items."
	L.CCMG_FinishedLooting = "[CCMG] Finished looting. Mail(s) from: %s"
	L.CCMG_Ignore = "[CCMG] Ignore: "
	L.CCMG_SentItems = "[CCMG] Items sent: "
	L.CCMG_IgnoredItems = "[CCMG] Items ignored: "
	L.CCMG_BankMsg = "[CCMG] You have  <<1[no items/one item/$d items]>> in your bank that could be sent. Visit a banker and run CCMG again to transfer them to your inventory."
	L.CCMG_Transferring = "[CCMG] Taking items from bank..."
	L.CCMG_NoTransfer = "[CCMG] Nothing to transfer."
	L.CCMG_XoutofY = "[CCMG] %s out of %s: %s"
	L.CCMG_NotEnoughSpace = "[CCMG] Inventory is full."
	L.CCMG_TransferFail = "[CCMG] Failed to transfer item - please try again."
	L.CCMG_InventoryFull = "[CCMG] Your inventory is full. Auto-looting stopped."
	L.CCMG_NothingToSend = "[CCMG] Nothing to send."	
	
	L.CCMG_Context = "Add context menu to chat"
	L.CCMG_ContextGuild = "Add context menu to guild roster"
	L.CCMG_ContextSet = "[CCMG] Set as recipient"
	L.CCMG_ContextSetSend = "[CCMG] Send set items (without mail group)..."
	L.CCMG_SendDirectly = "CCMG - Send directly to player"
	L.CCMG_SendDirectlyIsRecipient = "You selected to send items direclty to %s. This player is also the standard recipient in your collection mail group. Sending items directly will not save the items as 'sent' for the collection mail group. Do you really want to send them directly?"
	L.CCMG_SendDirectlyNoLMAS = "LibMultiAccountSets has not been found or no data for <<1>> has been found. CCMG will still remember the items, that have already been sent to <<1>>, but can't rely on LMAS data. Send anyway?"
	L.CCMG_NewRecipient = "[CCMG] |H0:character:%s|h%s|h was set as recipient."
	
for stringId, stringValue in pairs(L) do
	ZO_CreateStringId(stringId, stringValue)
end