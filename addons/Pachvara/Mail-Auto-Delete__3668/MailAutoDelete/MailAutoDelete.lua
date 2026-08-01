-- Addon namespace
MailAutoDelete = {}

MailAutoDelete.name = "MailAutoDelete"

local logger = LibDebugLogger(MailAutoDelete.name)

function MailAutoDelete.Initialize()
    EVENT_MANAGER:RegisterForEvent(MailAutoDelete.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS , MailAutoDelete.OnAttachedItemTake)
    EVENT_MANAGER:RegisterForEvent(MailAutoDelete.name, EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS , MailAutoDelete.OnAttachedMoneyTake)
end

function MailAutoDelete.OnAddOnLoaded(event, addonName)
    if addonName == MailAutoDelete.name then
        MailAutoDelete.Initialize()
        EVENT_MANAGER:UnregisterForEvent(MailAutoDelete.name, EVENT_ADD_ON_LOADED)
    end
end

function MailAutoDelete.OnAttachedItemTake(event, mailId)
    logger:Debug("OnAttachedItemTake", mailId)
    MailAutoDelete.CollectAllAndDelete(mailId)
end

function MailAutoDelete.OnAttachedMoneyTake(event, mailId)
    logger:Debug("OnAttachedMoneyTake", mailId)
    MailAutoDelete.CollectAllAndDelete(mailId)
end

function MailAutoDelete.CollectAllAndDelete(mailId)
    logger:Debug("Collecting the rest and deleting the mail", mailId)

    -- Collecting attached items and money just to be sure player collected everything.
    TakeMailAttachedItems(mailId)
    TakeMailAttachedMoney(mailId)

    -- Deleting the mail.
    DeleteMail(mailId, false)
end

EVENT_MANAGER:RegisterForEvent(MailAutoDelete.name, EVENT_ADD_ON_LOADED, MailAutoDelete.OnAddOnLoaded)