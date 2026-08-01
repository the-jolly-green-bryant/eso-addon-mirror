local MIS = {
Name = "MailInventorySpace",
Author = "Rhyono",
Version = "1.20"}

local function OnAddOnLoaded(event, addonName)
	if addonName == MIS.Name then 
		bagSpaceIcon = CreateControl("BagSpaceIcon", ZO_MailInbox, CT_TEXTURE)
			bagSpaceIcon:SetDimensions(24,24)
			bagSpaceIcon:SetAnchor(LEFT, ZO_MailInboxUnread, LEFT, 5, 30)
			bagSpaceIcon:SetTexture("/EsoUI/Art/MainMenu/menuBar_inventory_down.dds")

		bagSpaceLabel = CreateControl("BagSpaceLabel", ZO_MailInbox, CT_LABEL)
			bagSpaceLabel:SetColor(1, 1, 1, 1)
			bagSpaceLabel:SetFont("ZoFontGameBold")
			bagSpaceLabel:SetText("")
			bagSpaceLabel:SetAnchor(LEFT, bagSpaceIcon, RIGHT, 7, 0)
			bagSpaceLabel:SetDimensions(80,25)
	end
end

local function UpdateSpace(eventCode,mailId) 
	bagSpaceLabel:SetText(GetNumBagUsedSlots(1) .. '/' .. GetBagSize(1))
	if GetBagSize(1) ==	GetNumBagUsedSlots(1) then
		bagSpaceLabel:SetColor(1,0,0,1)
	elseif (GetBagSize(1)-GetNumBagUsedSlots(1)) <= 5 then
		bagSpaceLabel:SetColor(1,0.9,0,1)
	else
		bagSpaceLabel:SetColor(1, 1, 1, 1)
	end
end	

EVENT_MANAGER:RegisterForEvent(MIS.Name, EVENT_MAIL_OPEN_MAILBOX, UpdateSpace)	
EVENT_MANAGER:RegisterForEvent(MIS.Name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, UpdateSpace)
EVENT_MANAGER:RegisterForEvent(MIS.Name, EVENT_MAIL_SEND_SUCCESS, UpdateSpace)
EVENT_MANAGER:RegisterForEvent(MIS.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)