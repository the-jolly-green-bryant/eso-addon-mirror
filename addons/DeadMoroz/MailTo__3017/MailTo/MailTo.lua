-- MailTo
-- By @DeadMoroz (PC / EU)

MailTo = {}
MailTo.addonName = "MailTo"
MailTo.version = 1 -- saved vars
MailTo.versionString = "1.0.0"
MailTo.author = "@DeadMoroz (PC / EU)"

MailTo.menuTitle = "Send mail"

function MailTo.MailSend(address)
  if MAIL_SEND:IsHidden() then
    MAIL_SEND:ComposeMailTo(address)
  else
    MAIL_SEND:SetReply(address)
  end

end

function MailTo.PlayerContextMenu(playerName, rawName)
  AddCustomMenuItem(GetString(MAIL_TO_TITLE), function()
    MailTo.MailSend(playerName)
  end)
  return
end

function MailTo.onInitialize(event, addonName)

	if addonName == MailTo.addonName then
		EVENT_MANAGER:UnregisterForEvent(MailTo.addonName, EVENT_ADD_ON_LOADED)
    local LCM = LibCustomMenu
    if LCM == nil then
      return
    end

    LCM:RegisterPlayerContextMenu(MailTo.PlayerContextMenu, LCM.CATEGORY_LATE)
	end
end

EVENT_MANAGER:RegisterForEvent(MailTo.addonName, EVENT_ADD_ON_LOADED, MailTo.onInitialize)
