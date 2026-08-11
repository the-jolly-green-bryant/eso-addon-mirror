-- MailHistoryConsole — console (gamepad UI) port of Mail History by @PacificOshie.

MailHistory = {}
MailHistory.name = "MailHistoryConsole"

MailHistory.data = nil  -- SavedVars
MailHistory.settings = nil  -- SavedVars

-- Limit saved mail to 5000.  The number of mail affects memory usage, disk space, and performance.
-- Used with MailHistory.settings.numMailToKeep variable.
MailHistory.SAVED_MAIL_MIN = 100
MailHistory.SAVED_MAIL_MAX = 5000
MailHistory.SAVED_MAIL_DEFAULT = 100








-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- DATA TABLE
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- MailHistory.data.table is indexed.  Use ipairs (not pairs).  Use index,value (not key,value).
-- New entries are inserted at the beginning of the table, index 1.
-- Old entries are removed from the end of the table.
-- Entries are inserted when mail data is received; meaning, the table order may not match the mail timestamp order.

function MailHistory.DataTableUpdated()
    -- Remove table entries that are beyond the number of mail to keep.
    local indexToRemove = MailHistory.settings.numMailToKeep + 1
    while MailHistory.data.table[indexToRemove] ~= nil do
        table.remove(MailHistory.data.table, indexToRemove)
    end

    MailHistory.RefreshHistoryList()
end








-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- TEXT STRING FORMATTING
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

function MailHistory.StringRemoveCodes(str)
    if str == nil or str == "" then return "" end

    local ret = str

    -- Remove colors, but leave the inner text.
    -- |cFFFFFFinnertext|r
    ret = string.gsub(ret, "|[cC]%x%x%x%x%x%x", "")
    ret = string.gsub(ret, "|[rR]", "")

    -- Remove icons.
    -- |u0:6%:currency:|u|t80%:80%:/esoui/art/currency/gold_mipmap.dds|t
    ret = string.gsub(ret, "|u(.-):(.-)|u|t(.-):(.-)|t", "")
    ret = string.gsub(ret, "|t(.-):(.-)|t", "")

    -- Replace item links with the link's display text.
    -- |H0:item:54174:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
    repeat
        local itemLinkStart, itemLinkEnd = string.find(ret, "|H%d:item:(.-)|h(.-)|h", 1)
        if itemLinkStart then
            local itemLink = string.sub(ret, itemLinkStart, itemLinkEnd)
            local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
            ret = string.gsub(ret, itemLink, itemName)
        end
    until itemLinkStart == nil

    -- Replace other links with their basic display name.
    -- |H1:display:PacificOshie|h@PacificOshie|h
    -- |H1:guild:000000|hGuild|h
    ret = string.gsub(ret, "|H(.-):(.-)|h(.-)|h", "[%3]")

    return ret
end

-- GetTextFor(mail, textFor)
MailHistory.TEXT_FOR_CHAT = 1  -- Shortest text to display in chat.  Includes markup.
MailHistory.TEXT_FOR_ROW = 2  -- Short text for a gamepad list row.  WITHOUT MARKUP.
MailHistory.TEXT_FOR_POPUP = 3  -- Verbose text for the detail tooltip pane.  WITHOUT MARKUP.


function MailHistory.GetTextFor(mail, textFor)
    local textToConcat = {}

    -- Console: only chat output keeps markup; gamepad list rows render plain
    -- text (the list supplies its own icon and selection colors).
    local includeMarkup = (textFor == MailHistory.TEXT_FOR_CHAT)
    -- Is a multiline display requiring additional linefeed.
    local isMultiline = (textFor == MailHistory.TEXT_FOR_POPUP)


    local function AddFormatting(text, addHighlight, prependLinefeed)
        if addHighlight and prependLinefeed then
            return zo_strformat("\r\n|cffffff<<1>>|r", text)
        elseif addHighlight then
            return zo_strformat("|cffffff<<1>>|r", text)
        elseif prependLinefeed then
            return zo_strformat("\r\n<<1>>", text)
        else
            return text
        end
    end

    -- Determine if we're sending the mail or not.
    local sending = (GetDisplayName() == mail.from)

    -- Display this addon's identifier.
    if textFor == MailHistory.TEXT_FOR_CHAT then
        if (sending and MailHistory.settings.chatSentMail) or (not sending and MailHistory.settings.chatReadMail) then
            table.insert(textToConcat, "[MH]")
        else
            -- The chat settings are turned off.
            return false
        end
    end

    -- Display the action icon.
    if includeMarkup then
        if sending then  -- SENT
            table.insert(textToConcat, "|t24:24:EsoUI/Art/mail/mail_tabicon_compose_down.dds|t")  -- Compose mail icon.
        elseif mail.rts then  -- RTS
            table.insert(textToConcat, "|t24:24:EsoUI/Art/mail/mail_inbox_returned.dds|t")  -- Return mail icon.
        else  -- RECEIVED
            table.insert(textToConcat, "|t24:24:EsoUI/Art/mail/mail_tabicon_inbox_down.dds|t")  -- Mail icon.
        end
    end

    -- Display the character who processed the mail.
    if textFor == MailHistory.TEXT_FOR_POPUP then
        table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_CHARACTER), includeMarkup, false))
    end
    if textFor == MailHistory.TEXT_FOR_ROW or
        textFor == MailHistory.TEXT_FOR_POPUP then
        if sending and mail.character ~= nil and mail.character ~= "" then
            table.insert(textToConcat, mail.character)
        elseif (not sending) and mail.removedBy ~= nil and mail.removedBy ~= "" then
            table.insert(textToConcat, mail.removedBy)
        else
            table.insert(textToConcat, "-")
        end
    end

    -- Display the mail date and time.  (Not in gamepad list rows — too cluttered on a TV.)
    if textFor == MailHistory.TEXT_FOR_POPUP then
        if sending then  -- SENT
            table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_DATETIME_SENT), includeMarkup, isMultiline))
        elseif mail.rts then  -- RTS
            table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_DATETIME_RTS), includeMarkup, isMultiline))
        else  -- RECEIVED
            table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_DATETIME_RECEIVED), includeMarkup, isMultiline))
        end
        -- This should be one "field", so concat before inserting into the table.
        local textDateTime = os.date(MailHistory.settings.displayDateFormat, mail.timestamp) .. ' ' .. os.date(MailHistory.settings.displayTimeFormat, mail.timestamp)
        table.insert(textToConcat, textDateTime)
    end

    -- Display who the mail is to or from.
    if sending then  -- SENT
        table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_TO), includeMarkup, isMultiline))
        if mail.duplicates then
            if textFor == MailHistory.TEXT_FOR_POPUP then
                -- List all recipients.
                table.insert(textToConcat, mail.to)
                for _, duplicate in ipairs(mail.duplicates) do
                    table.insert(textToConcat, duplicate.to)
                end
            else
                -- Indicate that there are multiple recipients for the same mail.
                table.insert(textToConcat, GetString(SI_MAILHISTORY_MAIL_TO_MULTIPLE))
            end
        else
            table.insert(textToConcat, mail.to)
        end
    else
        if mail.rts then  -- RTS
            -- Returned TO the player who we got it _from_.
            table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_TO), includeMarkup, isMultiline))
        else  -- RECEIVED
            table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_FROM), includeMarkup, isMultiline))
        end
        local mailFromText = mail.from
        if mail.fromSystem then mailFromText = zo_strformat(GetString(SI_MAILHISTORY_MAIL_SYSTEM_PREFIX), mailFromText) end
        if mail.fromCS then mailFromText = zo_strformat(GetString(SI_MAILHISTORY_MAIL_CS_PREFIX), mailFromText) end
        table.insert(textToConcat, mailFromText)
    end

    -- Display the mail subject.
    if textFor == MailHistory.TEXT_FOR_ROW or
        textFor == MailHistory.TEXT_FOR_POPUP then
        table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_SUBJECT), includeMarkup, isMultiline))
        if includeMarkup then
            table.insert(textToConcat, mail.subject)
        else
            table.insert(textToConcat, MailHistory.StringRemoveCodes(mail.subject))
        end
    end

    -- Gamepad list rows end here: character, to/from, and subject only.
    if textFor == MailHistory.TEXT_FOR_ROW then
        return table.concat(textToConcat, " ")
    end

    -- Display the mail body.
    if textFor == MailHistory.TEXT_FOR_POPUP then
        if isMultiline then table.insert(textToConcat, "\r\n") end
        if includeMarkup then
            table.insert(textToConcat, AddFormatting(mail.body, false, isMultiline))
        else
            table.insert(textToConcat, AddFormatting(MailHistory.StringRemoveCodes(mail.body), false, isMultiline))
        end
        if isMultiline then table.insert(textToConcat, "\r\n") end
    end

    -- Display the attachments heading.
    if textFor == MailHistory.TEXT_FOR_POPUP then
        table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_ATTACHMENTS), includeMarkup, isMultiline))
    end

    local hasGoldOrCOD = false

    -- Display the gold attachment.
    local goldText = ''
    if mail.gold and mail.gold > 0 then
        hasGoldOrCOD = true
        goldText = ZO_CurrencyControl_FormatCurrency(mail.gold)
        if sending then  -- SENT
            if includeMarkup then
                goldText = zo_strformat("|cff3333<<1>>|r|t16:16:EsoUI/Art/currency/currency_gold.dds|t", goldText)  --red (sending gold)
            end
            goldText = AddFormatting(zo_strformat(GetString(SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_SENT), goldText), false, isMultiline)
        elseif mail.rts then  -- RTS
            if includeMarkup then
                goldText = zo_strformat("|cffffff<<1>>|r|t16:16:EsoUI/Art/currency/currency_gold.dds|t", goldText)  --white (returned)
            end
            goldText = AddFormatting(zo_strformat(GetString(SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_RTS), goldText), false, isMultiline)
        else  -- RECEIVED
            if includeMarkup then
                goldText = zo_strformat("|c33ff33<<1>>|r|t16:16:EsoUI/Art/currency/currency_gold.dds|t", goldText)  --green (receiving gold)
            end
            goldText = AddFormatting(zo_strformat(GetString(SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_RECEIVED), goldText), false, isMultiline)
        end
    end
    table.insert(textToConcat, goldText)

    -- Display the cod information.
    local codText = ''
    if mail.cod and mail.cod > 0 then
        hasGoldOrCOD = true
        codText = ZO_CurrencyControl_FormatCurrency(mail.cod)
        if sending then  -- SENT
            if includeMarkup then
                codText = zo_strformat("|cffffff<<1>>|r|t16:16:EsoUI/Art/currency/currency_gold.dds|t", codText)  --white (sending cod request)
            end
            codText = AddFormatting(zo_strformat(GetString(SI_MAILHISTORY_MAIL_ATTACHMENT_COD_SENT), codText), false, isMultiline)
        elseif mail.rts then  -- RTS
            if includeMarkup then
                codText = zo_strformat("|cffffff<<1>>|r|t16:16:EsoUI/Art/currency/currency_gold.dds|t", codText)  --white (returned cod)
            end
            codText = AddFormatting(zo_strformat(GetString(SI_MAILHISTORY_MAIL_ATTACHMENT_COD_RTS), codText), false, isMultiline)
        else  -- RECEIVED
            if includeMarkup then
                codText = zo_strformat("|cff3333<<1>>|r|t16:16:EsoUI/Art/currency/currency_gold.dds|t", codText)  --red (receiving mail, so sending cod payment)
            end
            codText = AddFormatting(zo_strformat(GetString(SI_MAILHISTORY_MAIL_ATTACHMENT_COD_RECEIVED), codText), false, isMultiline)
        end
    end
    table.insert(textToConcat, codText)

    -- Display all attached items.
    local attachmentsTextList = {}
    for index, attachment in ipairs(mail.attachments) do
        if attachment then
            if attachment.stack > 0 then
                if includeMarkup then
                    table.insert(attachmentsTextList, zo_strformat("<<1>>x<<2>>", attachment.stack, attachment.link))
                else
                    local itemText = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(attachment.link))
                    table.insert(attachmentsTextList, AddFormatting(zo_strformat("<<1>>x[<<2>>]", attachment.stack, itemText), false, isMultiline))
                end
            elseif attachment.icon and string.find(attachment.icon, "missing", 1, true) then
                table.insert(attachmentsTextList, AddFormatting(GetString(SI_MAILHISTORY_MAIL_ATTACHMENT_MISSING), false, isMultiline))
            end
        end
    end

    if #attachmentsTextList > 0 then
        -- Adding all attachments at once, so this is just one "field" for the export.
        local attachmentsText = table.concat(attachmentsTextList, " ")
        table.insert(textToConcat, attachmentsText)
    elseif not hasGoldOrCOD then
        table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_ATTACHMENT_NONE), false, isMultiline))
    end

    return table.concat(textToConcat, " ")
end








-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- MAIL SEND
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- SEND SCENARIO:
-- Sending a newly drafted mail to a player.  This scenario excludes sending cod payments.
--   1. SendMail.  Temporarily save the drafted mail data.
--   2. EVENT_MAIL_SEND_SUCCESS.  Process succeeded, so put the drafted mail data into the mail history.


-- This holds the draft mail data between clicking on send and receiving confirmation that it sent successfully.
MailHistory.draftMail = {}

-- This is called before SendMail executes.
-- This function temporarily saves the drafted mail data.
function MailHistory.MailSend_Draft(mailTo, mailSubject, mailBody)
    -- Reset the draftMail.
    ZO_ClearTable(MailHistory.draftMail)

    MailHistory.draftMail = {
        timestamp = os.time(),
        show = true,
        id = false,  -- There is no id for SENT mail.
        from = GetDisplayName(),
        character = GetUnitName("player"),
        fromSystem = false,
        fromCS = false,
        to = mailTo,
        rts = false,
        subject = mailSubject,
        body = mailBody,
        cod = GetQueuedCOD(),
        gold = GetQueuedMoneyAttachment(),
        postage = GetQueuedMailPostage(),
        attachments = {false,false,false,false,false,false},
        -- Duplicates of SENT mail is false when none, otherwise it's a table of multiple [1]={to,timestamp}
        duplicates = false,
    }
    for a=1,MAIL_MAX_ATTACHED_ITEMS do
        local bagId, slotIndex, icon, stack = GetQueuedItemAttachmentInfo(a)
        if stack > 0 then
            local link = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
            MailHistory.draftMail.attachments[a] = { icon=icon, stack=stack, link=link }
        end
    end

    -- PreHook must return false to continue.
    return false
end

-- This is called when a mail was sent successfully.
-- This function puts the drafted mail data into the mail history only when sending mail to a player.
function MailHistory.OnMailSendSuccess(_)
    -- If there isn't a draftMail or a recipient, then this event might be from a system generated mail, like sending a cod payment in response to taking a mail.
    if not (MailHistory.draftMail and MailHistory.draftMail.to) then
        return
    end

    -- Update the timestamp to now.
    MailHistory.draftMail.timestamp = os.time()

    -- Compare SENT mail.
    -- The TO field and timestamp can be different.  Other fields must match.
    -- Returns TRUE when the two mail are duplicate even if they're sent to two different people.
    local function IsDuplicateSendMail(a, b)
        -- Compare from fields.
        if a.from ~= GetDisplayName() or a.from ~= b.from then return false end
        -- Compare subject and body.
        if a.subject ~= b.subject or a.body ~= b.body then return false end
        -- Compare COD and gold.
        if a.cod ~= b.cod or a.gold ~= b.gold then return false end
        -- Compare attachment count.
        if #a.attachments ~= #b.attachments then return false end
        -- Compare attachment details.
        for i, attachment in ipairs(a.attachments) do
            if attachment and b.attachments[i] then
                if attachment.stack ~= b.attachments[i].stack or
                    attachment.link ~= b.attachments[i].link or
                    attachment.icon ~= b.attachments[i].icon then
                    return false
                end
            elseif attachment or b.attachments[i] then
                -- Attachments differ (one has a value the other does not).
                return false
            end
        end
        -- All comparisons pass, so this is a duplicate mail.
        return true
    end

    -- GUILD LEADER feature here for mass mailings; to avoid excessive mail records.

    -- Check for a duplicate.
    local duplicateOfIndex = false
    for index,mail in ipairs(MailHistory.data.table) do
        local secondsDelta = MailHistory.draftMail.timestamp - mail.timestamp
        if secondsDelta > 7200 then
            -- Only check mail within a couple hours of this one.
            -- Skip the rest.  This works because the table is roughly in order.
            break
        end
        if IsDuplicateSendMail(MailHistory.draftMail, mail) then
            duplicateOfIndex = index
            break
        end
    end

    if duplicateOfIndex then
        -- Setup the table if this is the first duplicate.
        if not MailHistory.data.table[duplicateOfIndex].duplicates then
            MailHistory.data.table[duplicateOfIndex].duplicates = {}
        end
        -- Add duplicate info to the preexisting mail record.
        local duplicate = { to=MailHistory.draftMail.to, timestamp=MailHistory.draftMail.timestamp }
        table.insert(MailHistory.data.table[duplicateOfIndex].duplicates, duplicate)
    else
        -- Save the mail.
        -- ALWAYS keep mail that the player sends.  There isn't a setting to disable this (on purpose).
        -- Insert at index 1.  New entries are saved at the beginning of the table.
        table.insert(MailHistory.data.table, 1, ZO_DeepTableCopy(MailHistory.draftMail))
    end

    -- Log to chat.
    local chatMessage = MailHistory.GetTextFor(MailHistory.draftMail, MailHistory.TEXT_FOR_CHAT)
    if chatMessage then CHAT_ROUTER:AddSystemMessage(chatMessage) end

    MailHistory.DataTableUpdated()

    -- Reset the draftMail.
    ZO_ClearTable(MailHistory.draftMail)
end

-- NOTE: The upstream addon's Reply/Forward (prefilling the send screen via
-- ComposeMailTo/InsertBodyText) is deliberately absent from the console port.
-- Values written into the ZOS mail-send object from addon code are tainted;
-- the console send flow later reads them inside secure functions that call
-- private platform APIs (IsConsoleCommunicationRestricted,
-- ShowSelectFromUserListDialog), which then error with "insecure code".
-- There is no secure prefill path for addons on console.








-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- MAIL INBOX
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- TAKE SCENARIO:
-- Take a mail with gold, attachments, or cod.  This scenario includes sending cod payments.
--   1. ZO_MailInboxShared_TakeAll.   Put the current mail data into the mail history as pending.
--   ** DeleteMail.  DO NOTHING.  The mail data may not properly specify the gold or attachments, so do nothing.
--   ** OnMailSendSuccess.  DO NOTHING.  Only called when cod payment was sent and since that's not a drafted mail, so do nothing.
--   2. EVENT_MAIL_REMOVED.  Process succeeded, so update the pending mail in the mail history so it's available.

-- RTS SCENARIO:
-- Returning a mail to the sender.
--   1. ReturnMail.  Put the current mail data into the mail history as pending.
--   2. EVENT_MAIL_REMOVED.  Process succeeded, so update the pending mail in the mail history so it's available.

-- DELETE SCENARIO:
-- Deleting a mail from the inbox.  This scenario excludes taking mail with gold, attachments, or cod.
--   1. DeleteMail.  Put the current mail data into the mail history as pending.
--   2. EVENT_MAIL_REMOVED.  Process succeeded, so update the pending mail in the mail history so it's available.


-- This is called before ZO_MailInboxShared_TakeAll, ReturnMail, and DeleteMail execute.
-- This function puts the mail in the mail history as pending.
-- This preserves the original mail data since subsequent operations may modify the mail data before the process has completed, such as taking only some attachments due to a full backpack.
function MailHistory.MailInbox_Pending(mailId, isReturnToSender)
    local safeId = zo_getSafeId64Key(mailId)
    local safeRTS = isReturnToSender or false

    -- IMPORTANT: Reset the draftMail in case the system sends a cod payment that may appear like a draft mail was sent.
    -- Reset the draftMail.
    ZO_ClearTable(MailHistory.draftMail)

    -- Check if the mail already exists in the mail history.
    for _,mail in ipairs(MailHistory.data.table) do
        if mail.id and mail.id == safeId then
            -- Update the RTS field.
            mail.rts = safeRTS
            -- Mail already exists, so don't need to re-save it below, just return.
            return
        end
    end

    -- Gather the data to save.
    local mailData = {}
    ZO_MailInboxShared_PopulateMailData(mailData, mailId)

     -- The mailData should never be missing.
    if not mailData or not mailData.mailId then
        -- Some other addons process mail before Mail History can save the mail.
        local chatMessage = zo_strformat("<<1>>: <<2>>", MailHistory.name, GetString(SI_MAILHISTORY_CHAT_WARNING_MISSING_DATA))
        if MailHistory.settings.chatWarnings then CHAT_ROUTER:AddSystemMessage(chatMessage) end
        return
    end

    local readMail = {
        show = false,  --pending
        timestamp = (os.time() - mailData.secsSinceReceived),
        id = safeId,
        from = mailData.senderDisplayName,
        character = mailData.senderCharacterName,
        fromSystem = mailData.fromSystem,
        fromCS = mailData.fromCS,
        to = GetDisplayName(),
        rts = safeRTS,
        subject = mailData:GetFormattedSubject(),
        body = ReadMail(mailId),
        cod = mailData.codAmount,
        gold = mailData.attachedMoney,
        postage = 0,
        attachments = { false, false, false, false, false, false },
        -- Duplicates of SENT mail is false when none, otherwise it's a table of multiple [1]={to,timestamp}
        duplicates = false,
        -- Fields to track how the mail was removed.
        removedBy = GetUnitName("player"),  -- The character who took, returned, or deleted the mail.
        removedAt = os.time(),  -- The timestamp when the character took, returned, or deleted the mail.
    }
    -- Note, received attachments are always in order (1,2,3), even though they may have been sent in various slots (2,4,6).
    for a=1,mailData.numAttachments do
        local icon, stack = GetAttachedItemInfo(mailId, a)
        local link = GetAttachedItemLink(mailId, a, LINK_STYLE_BRACKETS)
        readMail.attachments[a] = { icon=icon, stack=stack, link=link }
    end

    -- Save the mail.  PENDING.  (mail.show==false)
    -- Insert at index 1.  New entries are saved at the beginning of the table.
    table.insert(MailHistory.data.table, 1, readMail)
    MailHistory.DataTableUpdated()
end

-- This is called when mail is removed from the inbox, such as when taking, returning, and deleting mail.
-- This function updates the pending inbox mail in the mail history so it's available.
function MailHistory.OnMailRemoved(_, mailId)
    local safeId = zo_getSafeId64Key(mailId)

    for index,mail in ipairs(MailHistory.data.table) do
        if mail.id == safeId then

            -- Update the mail so it is available (no longer pending).
            mail.show = true

            -- Log to chat.
            local chatMessage = MailHistory.GetTextFor(mail, MailHistory.TEXT_FOR_CHAT)
            if chatMessage then CHAT_ROUTER:AddSystemMessage(chatMessage) end

            -- Do not save System mail per settings.
            if mail.fromSystem and (not MailHistory.settings.saveSystemMail) then
                table.remove(MailHistory.data.table, index)
            end

            MailHistory.DataTableUpdated()
            break
        end
    end
end






































-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- INITIALIZE ADDON
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

function MailHistory.OnAddOnLoaded(_, addOnName)
    -- Only initialize our own addon.
    if (MailHistory.name ~= addOnName) then return end

    EVENT_MANAGER:UnregisterForEvent(MailHistory.name, EVENT_ADD_ON_LOADED)

    SLASH_COMMANDS["/mailhistory"] = function()
        MailHistory.ToggleHistoryScene()
    end

    -- <<<< SAVEDVARS
    -- Fresh console namespaces; no legacy PC data exists on console, so the
    -- upstream v4/v6 migration (and its ReloadUI) is intentionally absent.
    MailHistory.data = ZO_SavedVars:NewAccountWide("MailHistoryConsoleData", 1, nil, {table={}}, GetWorldName())

    MailHistory.settings = ZO_SavedVars:NewAccountWide("MailHistoryConsoleSettings", 1, nil, {
        showSystemMail = true,
        saveSystemMail = true,
        chatSentMail = false,
        chatReadMail = false,
        chatWarnings = false,
        numMailToKeep = MailHistory.SAVED_MAIL_DEFAULT,
        displayDateFormat = "%x",
        displayTimeFormat = "%X",
        listTextSize = "medium",  -- Row font in the history list: small / medium / large.
    })

    -- <<<< MAIL HOOKS

    -- Callbacks for mail send.
    ZO_PreHook("SendMail", MailHistory.MailSend_Draft)
    EVENT_MANAGER:RegisterForEvent(MailHistory.name, EVENT_MAIL_SEND_SUCCESS, MailHistory.OnMailSendSuccess)

    -- Callbacks for mail inbox.
    ZO_PreHook("ZO_MailInboxShared_TakeAll", function(mailId) MailHistory.MailInbox_Pending(mailId, false) return false end)
    ZO_PreHook("ReturnMail", function(mailId) MailHistory.MailInbox_Pending(mailId, true) return false end)
    ZO_PreHook("DeleteMail", function(mailId) MailHistory.MailInbox_Pending(mailId, false) return false end)
    EVENT_MANAGER:RegisterForEvent(MailHistory.name, EVENT_MAIL_READABLE,
        function(_, mailId) MailHistory.MailInbox_Pending(mailId, false) end)
    EVENT_MANAGER:RegisterForEvent(MailHistory.name, EVENT_MAIL_REMOVED, MailHistory.OnMailRemoved)

    -- <<<< UI
    MailHistory.InitHistoryScene()   -- MailHistoryScene.lua
    MailHistory.registerSettings()   -- settings.lua
end

EVENT_MANAGER:RegisterForEvent(MailHistory.name, EVENT_ADD_ON_LOADED, MailHistory.OnAddOnLoaded)
