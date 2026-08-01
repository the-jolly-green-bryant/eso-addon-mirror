-- /esoui/ingame/mail/keyboard/mailinbox_keyboard.lua

ZO_PreHook(MAIL_INBOX, "Delete", function( self )
	if (self.mailId) then
		if (not self.isMailFromGuild) then
			local numAttachments, attachedMoney = GetMailAttachmentInfo(self.mailId)
			if (numAttachments == 0 and attachedMoney == 0) then
				-- Prepare to select the next mail; transplanted from OnMailRemoved,
				-- since this needs to be done before removing the mail, not after
				local currentNode = self.navigationTree:GetSelectedNode()
				local nextNode = currentNode and currentNode:GetNextOrPreviousSiblingNode()
				if (nextNode) then
					self.selectMailIdOnRefresh = nextNode.data.mailId
				end

				-- Delete the mail
				DeleteMail(self.mailId)

				-- Suppress the original function
				return true
			end
		else
			MAIL_MANAGER:MarkGuildMailDeleted(self.mailId)
		end
	end

	-- Run the original function
	return false
end)
