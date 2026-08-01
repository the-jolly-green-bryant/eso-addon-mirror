local MSp = {
Name = "MailSpace",
Author = "Verling.P",
Version = "0.1.0"}

local function LoadAdd(event, addonName)
	if addonName == MSp.Name then 
		MailNumLabel = CreateControl("MailNumLabel", ZO_MailInbox, CT_LABEL)
			MailNumLabel:SetColor(1, 1, 1, 1)
			MailNumLabel:SetFont("ZoFontGameBold")
			MailNumLabel:SetText("")
			MailNumLabel:SetAnchor(LEFT, ZO_MailInboxUnread, LEFT, 55, 0)
			MailNumLabel:SetDimensions(180,25)

		invIcon = CreateControl("InvIcon", ZO_MailInbox, CT_TEXTURE)
			InvIcon:SetDimensions(24,24)
			InvIcon:SetAnchor(LEFT, ZO_MailInboxUnread, LEFT, 5, 25)
			InvIcon:SetTexture("/EsoUI/Art/MainMenu/menuBar_inventory_down.dds")

		invLabel = CreateControl("InvLabel", ZO_MailInbox, CT_LABEL)
			InvLabel:SetColor(1, 1, 1, 1)
			InvLabel:SetFont("ZoFontGameBold")
			InvLabel:SetText("")
			InvLabel:SetAnchor(LEFT, InvIcon, RIGHT, 25, 0)
			InvLabel:SetDimensions(180,25)
	end
end

local function UpdateMail(eventCode,mailId) 

        MailNumLabel:SetText(' - ' .. GetNumMailItems() .. ' / 72')
	if GetNumMailItems() >=	72 then
		MailNumLabel:SetColor(1,0.1,0,1)
	elseif (71-GetNumMailItems()) <= 5 then
		MailNumLabel:SetColor(1,1,0,1)
	else
		MailNumLabel:SetColor(1,1,1,1)
	end

	InvLabel:SetText(' - ' .. GetNumBagUsedSlots(1) .. ' / ' .. GetBagSize(1))
	if GetBagSize(1) == GetNumBagUsedSlots(1) then
		InvLabel:SetColor(1,0.1,0,1)
	elseif (GetBagSize(1)-GetNumBagUsedSlots(1)) <= 5 then
		InvLabel:SetColor(1,1,0,1)
	else
		InvLabel:SetColor(1, 1, 1, 1)
	end
end	

EVENT_MANAGER:RegisterForEvent(MSp.Name, EVENT_MAIL_OPEN_MAILBOX, UpdateMail)
EVENT_MANAGER:RegisterForEvent(MSp.Name, EVENT_MAIL_INBOX_UPDATE, UpdateMail)
EVENT_MANAGER:RegisterForEvent(MSp.Name, EVENT_MAIL_REMOVED, UpdateMail)
EVENT_MANAGER:RegisterForEvent(MSp.Name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, UpdateMail)
EVENT_MANAGER:RegisterForEvent(MSp.Name, EVENT_MAIL_SEND_SUCCESS, UpdateMail)
EVENT_MANAGER:RegisterForEvent(MSp.Name, EVENT_ADD_ON_LOADED, LoadAdd)

