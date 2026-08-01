-- CharacterMarkdown - API Layer - Mail
-- Abstraction for mail system

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.mail = {}

local api = CM.api.mail

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetNumMail()
    return CM.SafeCall(GetNumMailItems) or 0
end

function api.GetMailInfo(mailId)
    if not mailId then
        return nil
    end

    local success, senderDisplay, senderCharacter, subject, _, unread, _, _, _, numAttachments =
        CM.SafeCallMulti(GetMailItemInfo, mailId)

    if not success then
        return nil
    end

    local sender = senderDisplay or senderCharacter or "Unknown"
    if (not sender or sender == "") and GetMailSender then
        local senderSuccess, displayName, characterName = CM.SafeCallMulti(GetMailSender, mailId)
        if senderSuccess then
            sender = displayName or characterName or "Unknown"
        end
    end

    return {
        id = mailId,
        sender = sender or "Unknown",
        subject = subject or "",
        isRead = not unread,
        hasAttachments = (numAttachments or 0) > 0,
        attachmentCount = numAttachments or 0,
    }
end

function api.GetAllMail()
    local mailList = {}

    if not GetNextMailId then
        return mailList
    end

    local mailId = CM.SafeCall(GetNextMailId, nil)
    while mailId do
        local mailInfo = api.GetMailInfo(mailId)
        if mailInfo then
            table.insert(mailList, mailInfo)
        end
        mailId = CM.SafeCall(GetNextMailId, mailId)
    end

    return mailList
end

CM.DebugPrint("API", "Mail API module loaded")
