local LDM = LibDynamicMail
local LTF = LibTextFormat

local mailSend = MAIL_SEND

if IsInGamepadPreferredMode() or IsConsoleUI() then
  mailSend = MAIL_GAMEPAD:GetSend()
end

local function NormalizeAccountName(name)
    if not IsDecoratedDisplayName(name) then
        return DecorateDisplayName(name)
    end
    return name
end

local function populateGamepadFields(parsedRecipient, parsedSubject, parsedBody)
    EVENT_MANAGER:UnregisterForEvent(parsedRecipient.."LDMMailboxOpen", EVENT_MAIL_OPEN_MAILBOX)
    mailSend.initialBodyInsertText = parsedBody
    mailSend.initialContact = parsedRecipient
    mailSend.initialSubject = parsedSubject
end

function LDM:ComposeMail(to, subject, body, sendNow)
  local decoratedRecipient = NormalizeAccountName(to)

  if sendNow then
    RequestOpenMailbox()
    zo_callLater(function()
      SendMail(decoratedRecipient, subject, body)
      zo_callLater(
        CloseMailbox,
      100)
    end, 100)
  else
    if IsInGamepadPreferredMode() or IsConsoleUI() then
      if IsConsoleUI() then
        EVENT_MANAGER:RegisterForEvent(to.."LDMMailboxOpen", EVENT_MAIL_OPEN_MAILBOX , function()
          populateGamepadFields(decoratedRecipient, subject, body)
        end )
      else
        populateGamepadFields(decoratedRecipient, subject, body)
        MAIN_MENU_GAMEPAD:ShowScene("mailGamepad")
        ZO_GamepadGenericHeader_SetActiveTabIndex(MAIN_MENU_GAMEPAD.header, 2)
      end
    populateGamepadFields(decoratedRecipient, subject, body)
    else
      mailSend.to:SetText(decoratedRecipient)
      mailSend.subject:SetText(subject)
      mailSend.body:SetText(body)
      MAIN_MENU_KEYBOARD:ShowScene("mailSend")
    end
  end
end
