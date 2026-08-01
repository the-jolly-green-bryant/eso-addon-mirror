-- English Version (MailBackPlease)
local L = {}

	L.SI_BINDING_NAME_MAILBACKPLEASE = "Send 6 items..."
	
	-- General UI
	L.MAILBACKPLEASE_Recipient = "Choose a friend to send the items to..."
	L.MAILBACKPLEASE_Recipient_TT = "All the mail back mails will be sent to this player"
	L.MAILBACKPLEASE_Shakespeare = "Random shakespeare quote"
	L.MAILBACKPLEASE_Shakespeare_TT = "Fill the message with a random shakespeare quote."
	L.MAILBACKPLEASE_OptionList = "Post complete list of sent items to chat."
	L.MAILBACKPLEASE_OptionAuto = "Continue sending mails until empty/user cancel."
	L.MAILBACKPLEASE_MasterWrit = "Master writs"
	L.MAILBACKPLEASE_Motifs = "Motifs"
	L.MAILBACKPLEASE_Recipes = "Recipes"
	L.MAILBACKPLEASE_FurniturePlans = "Furniture plans"
	L.MAILBACKPLEASE_SimpleEquipment = "Simple gear (white-blue quality, no sets)"
	L.MAILBACKPLEASE_Glyphs = "Glpyhs"
	L.MAILBACKPLEASE_NoRecipient = "[MBP]: Please choose a recipient via the addon options."
	L.MAILBACKPLEASE_ItemNumberSent = "[MBP] items sent to %s: %s"
	L.MAILBACKPLEASE_AlertHead = "Alert for exipring mails (on log-in)"
	L.MAILBACKPLEASE_AlertNumber = "Number of days before expiring"
	L.MAILBACKPLEASE_AlertNumberTooltip = "How many days before a mail is expiring do you want to be reminded?"
	L.MAILBACKPLEASE_AlertOnScreen = "Show an alert in the middle of the screen"
	L.MAILBACKPLEASE_AlertInChat = "Show an alert in chat"
	L.MAILBACKPLEASE_AlertTxtHead = "You have expiring mails!"
	L.MAILBACKPLEASE_AlertPlayer = "One of your player messages expires in |ced0000<<1[-/one day/$d days]>>|r."
	L.MAILBACKPLEASE_AlertSystem = "One of your system messages expires in |ced0000<<1[-/one day/$d days]>>|r."
	L.MAILBACKPLEASE_Subject = "Subject"
	L.MAILBACKPLEASE_MailSpecialFail = " [MBP] There seems to be a problem with one or more mails still in the queue - please check your inventory and try again if necassary."
	L.MAILBACKPLEASE_MailSuccess = " [MBP] Mail sent successfully to |H0:character:%s|h%s|h"
	L.MAILBACKPLEASE_MailFail = " [MBP] failed to send mail - "
	
	
for stringId, stringValue in pairs(L) do
	ZO_CreateStringId(stringId, stringValue)
end