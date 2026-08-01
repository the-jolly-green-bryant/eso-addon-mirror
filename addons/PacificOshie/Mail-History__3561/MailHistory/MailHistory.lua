-- MailHistory by @PacificOshie.  Have fun!

MailHistory = {}
MailHistory.name = "MailHistory"

MailHistory.data = nil  -- SavedVars
MailHistory.settings = nil  -- SavedVars

MailHistory.mainWindow = nil
MailHistory.scrollList = nil
MailHistory.popupWindow = nil
MailHistory.exportWindow = nil
MailHistory.exportPages = {}  -- Array of exported data pages.
MailHistory.exportPageNumber = 1  -- The currently displayed page of exported data.  One-based.

-- Limit saved mail to 5000.  The number of mail affects memory usage, disk space, and performance.
-- Used with MailHistory.settings.numMailToKeep variable.
MailHistory.SAVED_MAIL_MIN = 100
MailHistory.SAVED_MAIL_MAX = 5000
MailHistory.SAVED_MAIL_DEFAULT = 500








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

    if not MailHistory.mainWindow:IsHidden() then
        MailHistory.UpdateScrollList()
    end
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
MailHistory.TEXT_FOR_ROW = 2  -- Medium text to display as a row in the scroll list.  Includes markup.
MailHistory.TEXT_FOR_POPUP = 3  -- Verbose text to display in the popup window.  WITHOUT MARKUP.
MailHistory.TEXT_FOR_TOOLTIP = 4  -- Medium text to display as a row in the scroll list.  WITHOUT MARKUP.
MailHistory.TEXT_FOR_FORWARD_BODY = 5  -- Body text when forwarding mail.  WITHOUT MARKUP.
MailHistory.TEXT_FOR_EXPORT = 6  -- Verbose text to display as a row in the export window.  WITHOUT MARKUP.


function MailHistory.GetTextFor(mail, textFor)
    local textToConcat = {}

    -- Include markup for ESO color highlighting.
    local includeMarkup = (textFor == MailHistory.TEXT_FOR_CHAT or textFor == MailHistory.TEXT_FOR_ROW)
    -- Is a multiline display requiring additional linefeed.
    local isMultiline = (textFor == MailHistory.TEXT_FOR_POPUP or textFor == MailHistory.TEXT_FOR_TOOLTIP or textFor == MailHistory.TEXT_FOR_FORWARD_BODY)

    -- Input text: One "word" in quotes.
    -- Output text: "One ""word"" in quotes."
    local function EscapeQuotes(text)
        return '"' .. string.gsub(text, '"', '""') .. '"'
    end

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

    -- Display forward body prefix.
    if textFor == MailHistory.TEXT_FOR_FORWARD_BODY then
        table.insert(textToConcat, "\r\n----")
    end

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
    if textFor == MailHistory.TEXT_FOR_POPUP or
        textFor == MailHistory.TEXT_FOR_TOOLTIP then
        table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_CHARACTER), includeMarkup, false))
    end
    if textFor == MailHistory.TEXT_FOR_ROW or
        textFor == MailHistory.TEXT_FOR_POPUP or
        textFor == MailHistory.TEXT_FOR_TOOLTIP or
        textFor == MailHistory.TEXT_FOR_EXPORT then
        if sending and mail.character ~= nil and mail.character ~= "" then
            table.insert(textToConcat, mail.character)
        elseif (not sending) and mail.removedBy ~= nil and mail.removedBy ~= "" then
            table.insert(textToConcat, mail.removedBy)
        else
            table.insert(textToConcat, "-")
        end
    end

    -- Display the mail date and time.
    if textFor == MailHistory.TEXT_FOR_ROW or
        textFor == MailHistory.TEXT_FOR_POPUP or
        textFor == MailHistory.TEXT_FOR_TOOLTIP or
        textFor == MailHistory.TEXT_FOR_FORWARD_BODY or
        textFor == MailHistory.TEXT_FOR_EXPORT then
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
        textFor == MailHistory.TEXT_FOR_POPUP or
        textFor == MailHistory.TEXT_FOR_TOOLTIP then
        table.insert(textToConcat, AddFormatting(GetString(SI_MAILHISTORY_MAIL_SUBJECT), includeMarkup, isMultiline))
        if includeMarkup then
            table.insert(textToConcat, mail.subject)
        else
            table.insert(textToConcat, MailHistory.StringRemoveCodes(mail.subject))
        end
    elseif textFor == MailHistory.TEXT_FOR_EXPORT then
        local textToAdd = MailHistory.StringRemoveCodes(mail.subject)
        table.insert(textToConcat, AddFormatting(EscapeQuotes(textToAdd), includeMarkup, isMultiline))
    end

    -- Display the mail body.
    if textFor == MailHistory.TEXT_FOR_POPUP or
        textFor == MailHistory.TEXT_FOR_FORWARD_BODY then
        if isMultiline then table.insert(textToConcat, "\r\n") end
        if includeMarkup then
            table.insert(textToConcat, AddFormatting(mail.body, false, isMultiline))
        else
            table.insert(textToConcat, AddFormatting(MailHistory.StringRemoveCodes(mail.body), false, isMultiline))
        end
        if isMultiline then table.insert(textToConcat, "\r\n") end
    elseif textFor == MailHistory.TEXT_FOR_EXPORT then
        local textToAdd = MailHistory.StringRemoveCodes(mail.body)
        table.insert(textToConcat, AddFormatting(EscapeQuotes(textToAdd), includeMarkup, isMultiline))
    end

    -- Display the attachments heading.
    if textFor == MailHistory.TEXT_FOR_ROW or
        textFor == MailHistory.TEXT_FOR_POPUP or
        textFor == MailHistory.TEXT_FOR_TOOLTIP or
        textFor == MailHistory.TEXT_FOR_FORWARD_BODY then
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
    if textFor == MailHistory.TEXT_FOR_EXPORT then
        table.insert(textToConcat, EscapeQuotes(goldText))
    else
        table.insert(textToConcat, goldText)
    end

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
    if textFor == MailHistory.TEXT_FOR_EXPORT then
        table.insert(textToConcat, EscapeQuotes(codText))
    else
        table.insert(textToConcat, codText)
    end

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

    local returnText = ''
    if textFor == MailHistory.TEXT_FOR_EXPORT then
        returnText = table.concat(textToConcat, MailHistory.settings.exportSeparator)
        -- Replace any newlines with a pipe separator.
        returnText = string.gsub(returnText, "\r\n", "|")
    else
        returnText = table.concat(textToConcat, " ")
    end

    -- Truncate the forward body.
    -- https://wiki.esoui.com/Constant_Values#MAIL_MAX_BODY_CHARACTERS
    -- MAIL_MAX_BODY_CHARACTERS = 700
    if textFor == MailHistory.TEXT_FOR_FORWARD_BODY and string.len(returnText) > MAIL_MAX_BODY_CHARACTERS then
        local truncatedMessage = GetString(SI_MAILHISTORY_MAILSEND_FORWARD_BODY_TRUNCATED)
        local truncateAt = (MAIL_MAX_BODY_CHARACTERS - string.len(truncatedMessage)) - 2
        returnText = zo_strformat("<<1>>\r\n<<2>>", string.sub(returnText, 1, truncateAt), truncatedMessage)
    end

    return returnText
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
    if chatMessage then CHAT_SYSTEM:AddMessage(chatMessage) end

    MailHistory.DataTableUpdated()

    -- Reset the draftMail.
    ZO_ClearTable(MailHistory.draftMail)
end

-- Compose a reply mail of the specified mail.
function MailHistory.MailSendReply(mail)
    local subject = zo_strformat("<<1>>: <<2>>",
        GetString(SI_MAILHISTORY_MAILSEND_REPLY_ABBREVIATION),
        MailHistory.StringRemoveCodes(mail.subject))

    if IsInGamepadPreferredMode() then
        -- Gamepad.
        SCENE_MANAGER:CreateStackFromScratch("mainMenuGamepad", "mailManagerGamepad")
        MAIL_MANAGER_GAMEPAD:GetSend():InitializeFragment()
        MAIL_MANAGER_GAMEPAD:GetSend():ComposeMailTo(mail.from, subject)
        MAIL_MANAGER_GAMEPAD:GetSend():SwitchToSendTab()
    else
        -- Keyboard.
        MAIN_MENU_KEYBOARD:ShowSceneGroup("mailSceneGroup", "mailSend")
        MAIL_SEND:SetReply(mail.from, subject)
        -- Put the keyboard cursor in the BODY field.
        ZO_MailSendBodyField:TakeFocus()
    end
end

-- Compose a mail to forward the specified mail to someone; without attachments, just includes the mail body.
function MailHistory.MailSendForward(mail)
    local subject = zo_strformat("<<1>>: <<2>>",
        GetString(SI_MAILHISTORY_MAILSEND_FORWARD_ABBREVIATION),
        MailHistory.StringRemoveCodes(mail.subject))
    local body = MailHistory.GetTextFor(mail, MailHistory.TEXT_FOR_FORWARD_BODY)

    if IsInGamepadPreferredMode() then
        -- Gamepad.
        SCENE_MANAGER:CreateStackFromScratch("mainMenuGamepad", "mailManagerGamepad")
        MAIL_MANAGER_GAMEPAD:GetSend():InitializeFragment()
        MAIL_MANAGER_GAMEPAD:GetSend():ComposeMailTo("", subject)
        MAIL_MANAGER_GAMEPAD:GetSend():InsertBodyText(body)
        MAIL_MANAGER_GAMEPAD:GetSend():SwitchToSendTab()
    else
        -- Keyboard.
        MAIN_MENU_KEYBOARD:ShowSceneGroup("mailSceneGroup", "mailSend")
        MAIL_SEND:SetReply("", subject)
        ZO_MailSendBodyField:SetText(body)
        -- Put the keyboard cursor in the TO field.
        ZO_MailSendToField:TakeFocus()
    end
end








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
        if MailHistory.settings.chatWarnings then CHAT_SYSTEM:AddMessage(chatMessage) end
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
            if chatMessage then CHAT_SYSTEM:AddMessage(chatMessage) end

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
-- MAIN WINDOW
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

function MailHistory.ShowMainWindow()
    -- Update the data and show the Mail History main window when the mailbox opens.
    MailHistory.UpdateScrollList()
    MailHistory.mainWindow:SetHidden(false)
end

function MailHistory.HideMainWindow()
    MailHistory.popupWindow:SetHidden(true)
    MailHistory.HideExportWindow()
    -- Hide the Mail History main window when the mailbox closes.
    MailHistory.mainWindow:SetHidden(true)
end

function MailHistory.SaveMainWindowPosition(mainWindow)
    MailHistory.settings.mainWindowPositionX = mainWindow:GetLeft()
    MailHistory.settings.mainWindowPositionY = mainWindow:GetTop()
    MailHistory.settings.mainWindowPositionW, MailHistory.settings.mainWindowPositionH = mainWindow:GetDimensions()
end

function MailHistory.OnMainWindowResizeStart(mainWindow)
	EVENT_MANAGER:RegisterForUpdate("MailHistory_MainWindowResize", 10, function() MailHistory.UpdateScrollList() end)
end

function MailHistory.OnMainWindowResizeStop(mainWindow)
	EVENT_MANAGER:UnregisterForUpdate("MailHistory_MainWindowResize")
	MailHistory.SaveMainWindowPosition(mainWindow)
end

function MailHistory.OnMainWindowMoveStop(mainWindow)
	MailHistory.SaveMainWindowPosition(mainWindow)
end








-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- SCROLLLIST
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- MailHistory_ScrollListAsyncTask
MailHistory.scrollListAsyncTask = LibAsync:Create("MailHistory_ScrollListAsyncTask")

function MailHistory.UpdateScrollList()
    MailHistory.scrollListAsyncTask:Cancel()

    -- Hide the export window when the scroll list is updated.
    MailHistory.HideExportWindow()

	local dataCopy = ZO_DeepTableCopy(MailHistory.data.table)

    local dataList = ZO_ScrollList_GetDataList(MailHistory.scrollList)
	ZO_ScrollList_Clear(MailHistory.scrollList)

    local searchFilterTotal = 0  -- Number of mail being shown which matches the search filter.
    local unfilteredTotal = 0  -- Total number of show-able mail.

    local searchFilter = zo_strlower(MailHistory.mainWindowFilterEditBox:GetText())
    local matching = (searchFilter and searchFilter ~= "")

    -- Add entries to the scroll list.  This function adds one entry.
    local function AddEntry(index, mail)
        -- Update the progress bar.
        if matching then
            MailHistory.mainWindowFilterProgressBar:SetValue(index)
            --NOTE: Not showing progress when loading data (only when matching) because loading is so fast causing the ui to flicker.
        end

        -- Skip mail that has not yet been taken, returned, or deleted.  (i.e., pending)
        if not mail.show then return end

        -- Skip mail according to the settings showSystemMail.
        if mail.fromSystem and (not MailHistory.settings.showSystemMail) then return end

        unfilteredTotal = unfilteredTotal + 1

        -- check if a search filter is applied.
        if matching then
            local plainMailText = zo_strlower(MailHistory.GetTextFor(mail, MailHistory.TEXT_FOR_POPUP))
            if string.find(plainMailText, searchFilter, 1, true) and true or false then
                -- Found a match.
                searchFilterTotal = searchFilterTotal + 1
            else
                -- Skip mail that doesn't contain the search filter.
                return
            end
        end

        --Using typeId 1 per data type setup.  ref ZO_ScrollList_AddDataType.
        local entry = ZO_ScrollList_CreateDataEntry(1, mail)
        table.insert(dataList, entry)
    end

    -- Finalize the scroll list after all entries have been added.
    local function Commit()
        -- Sort the scroll list.
        table.sort(dataList, function(a,b)
            if a.data.timestamp == b.data.timestamp then
                if a.data.id and b.data.id then
                    return a.data.id > b.data.id
                else
                    return a.data.to > b.data.to
                end
            end
            return a.data.timestamp > b.data.timestamp
        end)

        -- Redraw the scroll list.
        ZO_ScrollList_Commit(MailHistory.scrollList)

        -- Update the status label.
        if matching then
            MailHistory.mainWindowStatusLabel:SetText(zo_strformat(GetString(SI_MAILHISTORY_MAINWINDOW_STATUS_SEARCHFILTER), tostring(searchFilterTotal), tostring(unfilteredTotal)))
        else
            MailHistory.mainWindowStatusLabel:SetText(zo_strformat(GetString(SI_MAILHISTORY_MAINWINDOW_STATUS_ALL), tostring(unfilteredTotal)))
        end

        MailHistory.mainWindowFilterProgressBar:SetHidden(true)
    end

    -- Prepare the progress bar before adding entries to the scroll list.
    MailHistory.mainWindowFilterProgressBar:SetMinMax(1, #dataCopy)
    MailHistory.mainWindowFilterProgressBar:SetValue(1)
    MailHistory.mainWindowFilterProgressBar:SetHidden(false)

    -- Reset the status.
    if matching then
        MailHistory.mainWindowStatusLabel:SetText(GetString(SI_MAILHISTORY_MAINWINDOW_STATUS_MATCHING))
    --NOTE: Not showing progress when loading data (only when matching) because loading is so fast causing the ui to flicker.
    -- else
    --     MailHistory.mainWindowStatusLabel:SetText(GetString(SI_MAILHISTORY_MAINWINDOW_STATUS_LOADING))
    end

	-- Create the data entries for the scroll list from the copy of the new data table.
    MailHistory.scrollListAsyncTask:For(ipairs(dataCopy)):Do(AddEntry):Then(Commit)
end

function MailHistory.SetupScrollListRowControl(row, mail, scrollList)
	row:SetFont("ZoFontGame")
	row:SetMaxLineCount(1) -- Forces the text to only use one row.  If it goes longer, the extra will not display.
	row:SetText(MailHistory.GetTextFor(mail, MailHistory.TEXT_FOR_ROW))
	row:SetHandler("OnMouseUp", function(control, button, upInside)
        if button == 1 and upInside then
            ZO_ScrollList_MouseClick(scrollList, row)
        elseif button == 2 and upInside then
            ClearMenu()
            AddCustomMenuItem(GetString(SI_MAILHISTORY_MAILSEND_REPLY), function()
                MailHistory.MailSendReply(mail)
                ZO_ScrollList_SelectData(MailHistory.scrollList, nil)
            end)
            AddCustomMenuItem(GetString(SI_MAILHISTORY_MAILSEND_FORWARD), function()
                MailHistory.MailSendForward(mail)
                ZO_ScrollList_SelectData(MailHistory.scrollList, nil)
            end)
            ShowMenu(control)
        end
    end)
    row:SetHandler("OnMouseEnter", function(self)
        if MailHistory.settings.showTooltipSummary then
            ZO_Tooltips_ShowTextTooltip(self, TOP, MailHistory.GetTextFor(mail, MailHistory.TEXT_FOR_TOOLTIP))
        end
    end)
    row:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
end

function MailHistory.OnScrollListRowSelected(previouslySelectedData, selectedData, isSelectingDuringRebuild)
    if selectedData then
        MailHistory.popupWindow:SetHidden(false)

        MailHistory.popupWindowEditBox:SetText(MailHistory.GetTextFor(selectedData, MailHistory.TEXT_FOR_POPUP))
        MailHistory.popupWindowEditBox:SetCursorPosition(0)  -- Scroll to top.

        MailHistory.popupWindowReplyButton:SetHandler("OnClicked", function()
            MailHistory.MailSendReply(selectedData)
            ZO_ScrollList_SelectData(MailHistory.scrollList, nil)
        end)
        MailHistory.popupWindowForwardButton:SetHandler("OnClicked", function()
            MailHistory.MailSendForward(selectedData)
            ZO_ScrollList_SelectData(MailHistory.scrollList, nil)
        end)

        MailHistory.popupWindow:BringWindowToTop()
    else
        -- Mail is not selected, so hide the popup window.
        MailHistory.popupWindow:SetHidden(true)
    end
end








-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- POPUP WINDOW
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

function MailHistory.OnPopupWindowMoveStop(popupWindow)
    MailHistory.settings.popupWindowPositionX = popupWindow:GetLeft()
    MailHistory.settings.popupWindowPositionY = popupWindow:GetTop()
end








-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- EXPORT WINDOW
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

function MailHistory.ShowExportWindow()
    -- The number of characters of exported data allowed per page.
    -- NOTICE: This is 256 less than actual to avoid mysterious data clipping.
    local exportPageSize = MailHistory.exportWindowEditBox:GetMaxInputChars() - 256

    MailHistory.exportPages = {}

    local currentPageRecords = {}  -- The running set of records for the current page.
    local currentPageRecordsDataSize = 0  -- The running size (total characters) of the records for the current page.

    -- The export columns header.
    local columnsHeader = {
        GetString(SI_MAILHISTORY_EXPORT_CHARACTER),
        GetString(SI_MAILHISTORY_EXPORT_STATUS),
        GetString(SI_MAILHISTORY_EXPORT_DATETIME),
        GetString(SI_MAILHISTORY_EXPORT_DIRECTION),
        GetString(SI_MAILHISTORY_EXPORT_NAME),
        GetString(SI_MAILHISTORY_EXPORT_SUBJECT),
        GetString(SI_MAILHISTORY_EXPORT_BODY),
        GetString(SI_MAILHISTORY_EXPORT_GOLD),
        GetString(SI_MAILHISTORY_EXPORT_COD),
        GetString(SI_MAILHISTORY_EXPORT_ATTACHMENTS),
    }
    local headerRecord = table.concat(columnsHeader, MailHistory.settings.exportSeparator)
    currentPageRecordsDataSize = currentPageRecordsDataSize + string.len(headerRecord) + 2
    table.insert(currentPageRecords, headerRecord)

    -- Add a record for each mail in the history.
    local dataList = ZO_ScrollList_GetDataList(MailHistory.scrollList)
    for _, entry in ipairs(dataList) do
        local record = MailHistory.GetTextFor(entry.data, MailHistory.TEXT_FOR_EXPORT)
        currentPageRecordsDataSize = currentPageRecordsDataSize + string.len(record) + 2

        -- Ensure this record will fit before adding it to the current page.
        if currentPageRecordsDataSize >= exportPageSize then
            -- End the current page.
            local exportText = table.concat(currentPageRecords, "\r\n") .. "\r\n"
            table.insert(MailHistory.exportPages, exportText)
            -- Start a new page for this record.
            currentPageRecords = {}
            currentPageRecordsDataSize = string.len(record) + 2
        end

        -- Continue adding records into the page.
        table.insert(currentPageRecords, record)
    end
    -- End the current page.
    local exportText = table.concat(currentPageRecords, "\r\n") .. "\r\n"
    table.insert(MailHistory.exportPages, exportText)

    -- Display the first page of data (pagination).
    MailHistory.GotoExportPage(0)
end

-- pageNumber: One-based page index to display.  First page is 1.
function MailHistory.GotoExportPage(pageNumber)
    local exportPageTotal = #MailHistory.exportPages

    -- Update exportPageNumber while ensuring it is within the valid range.
    if pageNumber < 1 then
        MailHistory.exportPageNumber = 1
    elseif pageNumber > exportPageTotal then
        MailHistory.exportPageNumber = exportPageTotal
    else
        MailHistory.exportPageNumber = pageNumber
    end

    MailHistory.exportWindowEditBox:SetText(MailHistory.exportPages[MailHistory.exportPageNumber])

    MailHistory.exportWindowStatusLabel:SetText(zo_strformat(GetString(SI_MAILHISTORY_EXPORTWINDOW_STATUS), MailHistory.exportPageNumber, exportPageTotal))

    MailHistory.exportWindow:SetHidden(false)
    MailHistory.exportWindow:BringWindowToTop()
    MailHistory.exportWindowEditBox:TakeFocus()
    MailHistory.exportWindowEditBox:SetCursorPosition(0)  -- Scroll to top.
end

function MailHistory.HideExportWindow()
    MailHistory.exportWindow:SetHidden(true)
end








-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- INITIALIZE ADDON
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

function MailHistory.OnMailOpenMailbox()
    if MailHistory.settings.autoToggleMainWindow then
        MailHistory.ShowMainWindow()
    end
end

function MailHistory.OnMailCloseMailbox()
    if MailHistory.settings.autoToggleMainWindow then
        MailHistory.HideMainWindow()
    end
end

function MailHistory.OnPlayerActivated(_, initial)
    -- Warn about known addon incompatibility.
    if MailR then
        local chatMessage = zo_strformat("<<1>>: <<2>>", MailHistory.name, GetString(SI_MAILHISTORY_CHAT_WARNING_MAILR))
        if MailHistory.settings.chatWarnings then CHAT_SYSTEM:AddMessage(chatMessage) end
    end

    MailHistory.UpdateScrollList()
end

function MailHistory.OnAddOnLoaded(_, addOnName)
    -- Only initialize our own addon.
    if (MailHistory.name ~= addOnName) then return end

    EVENT_MANAGER:UnregisterForEvent(MailHistory.name, EVENT_ADD_ON_LOADED)

    -- Callback when the player is activated.
    EVENT_MANAGER:RegisterForEvent(MailHistory.name, EVENT_PLAYER_ACTIVATED, MailHistory.OnPlayerActivated)

    -- Callback when opening and closing the mailbox (keyboard or gamepad).
    EVENT_MANAGER:RegisterForEvent(MailHistory.name, EVENT_MAIL_OPEN_MAILBOX, MailHistory.OnMailOpenMailbox)
    EVENT_MANAGER:RegisterForEvent(MailHistory.name, EVENT_MAIL_CLOSE_MAILBOX, MailHistory.OnMailCloseMailbox)

    SLASH_COMMANDS["/mailhistory"] = function()
        if MailHistory.mainWindow:IsHidden() then
            MailHistory.ShowMainWindow()
        else
            MailHistory.HideMainWindow()
        end
    end

    -- <<<< SAVEDVARS DATA / HISTORY

    -- This retrieves the history data (addon v7).
    MailHistory.data = ZO_SavedVars:NewAccountWide("MailHistoryDataV7", 1, nil, {table={}}, GetWorldName())

    -- Upgrade old history data if there isn't any V7 data yet.
    if ZO_IsTableEmpty(MailHistory.data.table) then

        -- This retrieves the old region server agnostic settings if they exist (addon v4).
        local v4Settings = ZO_SavedVars:NewAccountWide("MailHistoryData", 1, nil, {table={}})
        local v4HistoryTable = {}
        if not ZO_IsTableEmpty(v4Settings.table) then
            for _,v in ipairs(v4Settings.table) do
                table.insert(v4HistoryTable, v)
            end
        end

        -- https://github.com/esoui/esoui/blob/ea3a42c9344a610a1a49293f417b7c24db0da546/esoui/libraries/utility/zo_savedvars.lua#L16
        -- https://github.com/esoui/esoui/blob/ea3a42c9344a610a1a49293f417b7c24db0da546/esoui/libraries/utility/zo_savedvars.lua#L289
        -- So, if we ask for version 1 and there's a version 2, then we get version 2.
        -- And, if we ask for version 2 and there's only a version 1, then version 1 is destroyed and we get the default.

        -- This retrieves version 1 (addon v5) if it exists, otherwise retrieves version 2 (addon v6).
        -- NOTICE the default history table is v4HistoryTable.
        local v6Settings = ZO_SavedVars:NewAccountWide("MailHistoryData", 1, nil, {table=v4HistoryTable}, GetWorldName())
        local v6HistoryTable = {}
        if not ZO_IsTableEmpty(v6Settings.table) then
            for _,v in ipairs(v6Settings.table) do
                table.insert(v6HistoryTable, v)
            end
        end

        -- Put the history table into the SavedVars.
        MailHistory.data.table = v6HistoryTable

        -- Sort the history data for v7.
        table.sort(MailHistory.data.table, function(a,b)
            if a.timestamp == b.timestamp then
                if a.id and b.id then
                    return a.id > b.id
                else
                    return a.to > b.to
                end
            end
            return a.timestamp > b.timestamp
        end)

        -- Clear the old settings.
        if v4Settings then v4Settings.table = nil end
        if v6Settings then v6Settings.table = nil end

        if not ZO_IsTableEmpty(MailHistory.data.table) then
            -- ReloadUI to persist the data.
            ReloadUI("ingame")
        end
    end

    -- <<<< SAVEDVARS SETTINGS

    -- Settings are SavedVars version 1 and region agnostic.
    MailHistory.settings = ZO_SavedVars:NewAccountWide("MailHistorySettings", 1, nil, {
        autoToggleMainWindow = true,
        showSystemMail = true,
        showTooltipSummary = false,
        chatSentMail = false,
        chatReadMail = false,
        chatWarnings = false,
        saveSystemMail = true,
        numMailToKeep = MailHistory.SAVED_MAIL_DEFAULT,
        displayDateFormat = "%x",
        displayTimeFormat = "%X",
        mainWindowPositionX = 100,
        mainWindowPositionY = 100,
        mainWindowPositionW = 800,
        mainWindowPositionH = 450,
        popupWindowPositionX = 200,
        popupWindowPositionY = 200,
        exportSeparator = "\t",
    })

    -- Load the addon settings panel.
    MailHistory.LoadSettingsPanel()

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
    -- EVENT_MANAGER:RegisterForEvent(MailHistory.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS,
    --     function(_, mailId) MailHistory.MailInbox_Pending(mailId, false) end)
    EVENT_MANAGER:RegisterForEvent(MailHistory.name, EVENT_MAIL_REMOVED, MailHistory.OnMailRemoved)

    -- <<< MAIN WINDOW

    -- MailHistory_MainWindow
    MailHistory.mainWindow = WINDOW_MANAGER:CreateTopLevelWindow("MailHistory_MainWindow")
    MailHistory.mainWindow:ClearAnchors()
    MailHistory.mainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MailHistory.settings.mainWindowPositionX, MailHistory.settings.mainWindowPositionY)
    MailHistory.mainWindow:SetDimensions(MailHistory.settings.mainWindowPositionW, MailHistory.settings.mainWindowPositionH)
    MailHistory.mainWindow:SetDimensionConstraints(500, 250)
	MailHistory.mainWindow:SetHidden(true)
    MailHistory.mainWindow:SetMouseEnabled(true)
    MailHistory.mainWindow:SetMovable(true)
    MailHistory.mainWindow:SetResizeHandleSize(8)
    MailHistory.mainWindow:SetClampedToScreen(true)
    MailHistory.mainWindow:SetHandler("OnResizeStart", function(self) MailHistory.OnMainWindowResizeStart(self) end)
    MailHistory.mainWindow:SetHandler("OnResizeStop", function(self) MailHistory.OnMainWindowResizeStop(self) end)
    MailHistory.mainWindow:SetHandler("OnMoveStop", function(self) MailHistory.OnMainWindowMoveStop(self) end)

    -- MailHistory_MainWindow_Backdrop
    local mainWindowBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_MainWindow_Backdrop", MailHistory.mainWindow, "ZO_DefaultBackdrop")
	mainWindowBackdrop:SetAnchorFill(MailHistory.mainWindow)

    -- MailHistory_MainWindow_Title
    local mainWindowTitle = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_MainWindow_Title", MailHistory.mainWindow, "ZO_WindowTitle")
	mainWindowTitle:SetAnchor(TOPLEFT, MailHistory.mainWindow, TOPLEFT, 16, 12)
    mainWindowTitle:SetFont("ZoFontHeader3")
    mainWindowTitle:SetText("MAIL HISTORY")

    -- MailHistory_MainWindow_OptionsButton
    local options = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_MainWindow_OptionsButton", MailHistory.mainWindow, "ZO_DefaultButton")
	options:SetAnchor(TOPRIGHT, MailHistory.mainWindow, TOPRIGHT, -48, 12)
    options:SetHandler("OnClicked", function() DoCommand("/mailhistorysettings") end)
    options:SetText(GetString(SI_MAILHISTORY_MAINWINDOW_OPTIONSBUTTON))

    -- MailHistory_MainWindow_ExportButton
    local export = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_MainWindow_ExportButton", MailHistory.mainWindow, "ZO_DefaultButton")
	export:SetAnchor(TOPRIGHT, options, TOPLEFT, 0, 0)
    export:SetHandler("OnClicked", function() MailHistory.ShowExportWindow() end)
    export:SetText(GetString(SI_MAILHISTORY_MAINWINDOW_EXPORTBUTTON))

    -- MailHistory_MainWindow_CloseButton
    local mainWindowTitleCloseButton = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_MainWindow_CloseButton", MailHistory.mainWindow, "ZO_CloseButton")
	mainWindowTitleCloseButton:SetAnchor(TOPRIGHT, MailHistory.mainWindow, TOPRIGHT, -16, 16)
    mainWindowTitleCloseButton:SetHandler("OnClicked", function() MailHistory.HideMainWindow() end)

    -- MailHistory_MainWindow_HeaderDivider
    local mainWindowHeaderDivider = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_MainWindow_HeaderDivider", MailHistory.mainWindow, "ZO_HorizontalDivider")
    mainWindowHeaderDivider:SetAnchor(TOPLEFT, MailHistory.mainWindow, TOPLEFT, 0, 48)
    mainWindowHeaderDivider:SetAnchor(BOTTOMRIGHT, MailHistory.mainWindow, TOPRIGHT, 0, 56)

    -- MailHistory_MainWindow_FooterDivider
    local mainWindowFooterDivider = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_MainWindow_FooterDivider", MailHistory.mainWindow, "ZO_HorizontalDivider")
    mainWindowFooterDivider:SetAnchor(TOPLEFT, MailHistory.mainWindow, BOTTOMLEFT, 0, -72)
    mainWindowFooterDivider:SetAnchor(BOTTOMRIGHT, MailHistory.mainWindow, BOTTOMRIGHT, 0, -64)

    -- MailHistory_MainWindow_StatusLabel
    MailHistory.mainWindowStatusLabel = WINDOW_MANAGER:CreateControl("MailHistory_MainWindow_StatusLabel", MailHistory.mainWindow, CT_LABEL)
    MailHistory.mainWindowStatusLabel:SetAnchor(TOPLEFT, MailHistory.mainWindow, BOTTOMLEFT, 16, -66)
    MailHistory.mainWindowStatusLabel:SetAnchor(BOTTOMRIGHT, MailHistory.mainWindow, BOTTOMRIGHT, -16, -42)
    MailHistory.mainWindowStatusLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    MailHistory.mainWindowStatusLabel:SetFont("ZoFontGame")
    MailHistory.mainWindowStatusLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    MailHistory.mainWindowStatusLabel:SetDrawLayer(DL_TEXT)

    -- MailHistory_MainWindow_FilterBackdrop
    local mainWindowFilterBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_MainWindow_FilterBackdrop", MailHistory.mainWindow, "ZO_SingleLineEditBackdrop_Keyboard")
	mainWindowFilterBackdrop:SetAnchor(TOPLEFT, MailHistory.mainWindow, BOTTOMLEFT, 16, -42)
    mainWindowFilterBackdrop:SetAnchor(BOTTOMRIGHT, MailHistory.mainWindow, BOTTOMRIGHT, -16, -16)

    -- MailHistory_MainWindow_FilterEditBox
    MailHistory.mainWindowFilterEditBox = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_MainWindow_FilterEditBox", MailHistory.mainWindow, "ZO_DefaultEditForBackdrop")
	MailHistory.mainWindowFilterEditBox:SetAnchor(TOPLEFT, MailHistory.mainWindow, BOTTOMLEFT, 20, -40)
    MailHistory.mainWindowFilterEditBox:SetAnchor(BOTTOMRIGHT, MailHistory.mainWindow, BOTTOMRIGHT, -20, -18)
    MailHistory.mainWindowFilterEditBox:SetEditEnabled(true)
    MailHistory.mainWindowFilterEditBox:SetMaxInputChars(500)
    MailHistory.mainWindowFilterEditBox:SetDefaultText(GetString(SI_MAILHISTORY_MAINWINDOW_SEARCHFILTER_PROMPT))
    MailHistory.mainWindowFilterEditBox:SetHandler("OnTextChanged", function() MailHistory.UpdateScrollList() end)

    -- MailHistory_MainWindow_FilterResetButton
    local mainWindowFilterResetButton = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_MainWindow_FilterResetButton", MailHistory.mainWindow, "ZO_CloseButton")
	mainWindowFilterResetButton:SetAnchor(TOPRIGHT, MailHistory.mainWindow, BOTTOMRIGHT, -20, -38)
    mainWindowFilterResetButton:SetHandler("OnClicked", function() MailHistory.mainWindowFilterEditBox:SetText("") end)
    mainWindowFilterResetButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SI_MAILHISTORY_MAINWINDOW_SEARCHFILTER_RESET_TOOLTIP)) end)
    mainWindowFilterResetButton:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)

    -- MailHistory_MainWindow_FilterProgressBar
    MailHistory.mainWindowFilterProgressBar = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_MainWindow_FilterProgressBar", MailHistory.mainWindow, "ZO_DefaultStatusBar")
	MailHistory.mainWindowFilterProgressBar:SetAnchor(TOPLEFT, MailHistory.mainWindow, BOTTOMLEFT, 16, -42)
    MailHistory.mainWindowFilterProgressBar:SetAnchor(BOTTOMRIGHT, MailHistory.mainWindow, BOTTOMRIGHT, -16, -16)
    MailHistory.mainWindowFilterProgressBar:SetAlpha(0.33)

    -- <<< SCROLLLIST

    -- ScrollList
	MailHistory.scrollList = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_ScrollList", MailHistory.mainWindow, "ZO_ScrollList")
	MailHistory.scrollList:SetAnchor(TOPLEFT, MailHistory.mainWindow, TOPLEFT, 16, 60)
    MailHistory.scrollList:SetAnchor(BOTTOMRIGHT, MailHistory.mainWindow, BOTTOMRIGHT, -8, -72)

    -- Create the ScrollList DataType.
	local typeId = 1
	local templateName = "ZO_SelectableLabel"
	local height = 25  -- Height of the row.
	local setupFunction = MailHistory.SetupScrollListRowControl
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil
	local selectTemplate = "ZO_ThinListHighlight"
	local selectCallback = MailHistory.OnScrollListRowSelected
	ZO_ScrollList_AddDataType(MailHistory.scrollList, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
	ZO_ScrollList_EnableSelection(MailHistory.scrollList, selectTemplate, selectCallback)

    -- <<<< POPUP WINDOW

    -- MailHistory_PopupWindow
    MailHistory.popupWindow = WINDOW_MANAGER:CreateTopLevelWindow("MailHistory_PopupWindow")
    MailHistory.popupWindow:ClearAnchors()
    MailHistory.popupWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MailHistory.settings.popupWindowPositionX, MailHistory.settings.popupWindowPositionY)
    MailHistory.popupWindow:SetDimensions(480, 600)
	MailHistory.popupWindow:SetHidden(true)
    MailHistory.popupWindow:SetMouseEnabled(true)
    MailHistory.popupWindow:SetMovable(true)
    MailHistory.popupWindow:SetClampedToScreen(true)
    MailHistory.popupWindow:SetHandler("OnMoveStop", function(self) MailHistory.OnPopupWindowMoveStop(self) end)

    -- MailHistory_PopupWindow_Backdrop
    local popupWindowBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_PopupWindow_Backdrop", MailHistory.popupWindow, "ZO_DefaultBackdrop")
    popupWindowBackdrop:SetAnchorFill(MailHistory.popupWindow)

    -- MailHistory_PopupWindow_Title
    local popupWindowTitle = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_PopupWindow_Title", MailHistory.popupWindow, "ZO_WindowTitle")
	popupWindowTitle:SetAnchor(TOPLEFT, MailHistory.popupWindow, TOPLEFT, 16, 12)
    popupWindowTitle:SetFont("ZoFontHeader3")
    popupWindowTitle:SetText("MAIL HISTORY")

    -- MailHistory_PopupWindow_PrevButton
    local popupWindowPrevButton = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_PopupWindow_PrevButton", MailHistory.popupWindow, "ZO_PreviousArrowButton")
	popupWindowPrevButton:SetAnchor(TOP, MailHistory.popupWindow, TOP, -16, 16)
    popupWindowPrevButton:SetHandler("OnClicked", function() ZO_ScrollList_SelectPreviousData(MailHistory.scrollList) end)
    popupWindowPrevButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SI_MAILHISTORY_POPUPWINDOW_PREVBUTTON_TOOLTIP)) end)
    popupWindowPrevButton:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)

    -- MailHistory_PopupWindow_NextButton
    local popupWindowNextButton = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_PopupWindow_NextButton", MailHistory.popupWindow, "ZO_NextArrowButton")
	popupWindowNextButton:SetAnchor(TOP, MailHistory.popupWindow, TOP, 16, 16)
    popupWindowNextButton:SetHandler("OnClicked", function() ZO_ScrollList_SelectNextData(MailHistory.scrollList) end)
    popupWindowNextButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SI_MAILHISTORY_POPUPWINDOW_NEXTBUTTON_TOOLTIP)) end)
    popupWindowNextButton:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)

    -- MailHistory_PopupWindow_CloseButton
    local popupWindowCloseButton = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_PopupWindow_CloseButton", MailHistory.popupWindow, "ZO_CloseButton")
	popupWindowCloseButton:SetAnchor(TOPRIGHT, MailHistory.popupWindow, TOPRIGHT, -16, 16)
    -- Close the popup by deselecting the item from the scrollist.
    popupWindowCloseButton:SetHandler("OnClicked", function() ZO_ScrollList_SelectData(MailHistory.scrollList, nil) end)

    -- MailHistory_PopupWindow_HeaderDivider
    local popupWindowHeaderDivider = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_PopupWindow_HeaderDivider", MailHistory.popupWindow, "ZO_HorizontalDivider")
    popupWindowHeaderDivider:SetAnchor(TOPLEFT, MailHistory.popupWindow, TOPLEFT, 0, 48)
    popupWindowHeaderDivider:SetAnchor(BOTTOMRIGHT, MailHistory.popupWindow, TOPRIGHT, 0, 56)

    -- MailHistory_PopupWindow_EditBoxBackdrop
    local popupWindowEditBoxBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_PopupWindow_EditBoxBackdrop", MailHistory.popupWindow, "ZO_SingleLineEditBackdrop_Keyboard")
	popupWindowEditBoxBackdrop:SetAnchor(TOPLEFT, MailHistory.popupWindow, TOPLEFT, 16, 60)
    popupWindowEditBoxBackdrop:SetAnchor(BOTTOMRIGHT, MailHistory.popupWindow, BOTTOMRIGHT, -16, -48)

    -- MailHistory_PopupWindow_EditBox
    MailHistory.popupWindowEditBox = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_PopupWindow_EditBox", MailHistory.popupWindow, "ZO_DefaultEditMultiLineForBackdrop")
	MailHistory.popupWindowEditBox:SetAnchor(TOPLEFT, MailHistory.popupWindow, TOPLEFT, 20, 62)
    MailHistory.popupWindowEditBox:SetAnchor(BOTTOMRIGHT, MailHistory.popupWindow, BOTTOMRIGHT, -20, -50)
    MailHistory.popupWindowEditBox:SetEditEnabled(false)
    MailHistory.popupWindowEditBox:SetMaxInputChars(16000)

    -- MailHistory_PopupWindow_ReplyButton
    MailHistory.popupWindowReplyButton = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_PopupWindow_ReplyButton", MailHistory.popupWindow, "ZO_DefaultButton")
    MailHistory.popupWindowReplyButton:SetAnchor(TOPRIGHT, MailHistory.popupWindow, BOTTOM, 0, -40)
    MailHistory.popupWindowReplyButton:SetText(GetString(SI_MAILHISTORY_MAILSEND_REPLY))

    -- MailHistory_PopupWindow_ForwardButton
    MailHistory.popupWindowForwardButton = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_PopupWindow_ForwardButton", MailHistory.popupWindow, "ZO_DefaultButton")
    MailHistory.popupWindowForwardButton:SetAnchor(TOPLEFT, MailHistory.popupWindow, BOTTOM, 0, -40)
    MailHistory.popupWindowForwardButton:SetText(GetString(SI_MAILHISTORY_MAILSEND_FORWARD))

    -- <<<< EXPORT WINDOW

    -- MailHistory_ExportWindow
    MailHistory.exportWindow = WINDOW_MANAGER:CreateTopLevelWindow("MailHistory_ExportWindow")
    MailHistory.exportWindow:ClearAnchors()
    MailHistory.exportWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200, 200)
    MailHistory.exportWindow:SetDimensions(600, 400)
	MailHistory.exportWindow:SetHidden(true)
    MailHistory.exportWindow:SetMouseEnabled(true)
    MailHistory.exportWindow:SetMovable(true)
    MailHistory.exportWindow:SetClampedToScreen(true)

    -- MailHistory_ExportWindow_Backdrop
    local exportWindowBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_ExportWindow_Backdrop", MailHistory.exportWindow, "ZO_DefaultBackdrop")
    exportWindowBackdrop:SetAnchorFill(MailHistory.exportWindow)

    -- MailHistory_ExportWindow_Title
    local exportWindowTitle = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_ExportWindow_Title", MailHistory.exportWindow, "ZO_WindowTitle")
	exportWindowTitle:SetAnchor(TOPLEFT, MailHistory.exportWindow, TOPLEFT, 16, 12)
    exportWindowTitle:SetFont("ZoFontHeader3")
    exportWindowTitle:SetText(GetString(SI_MAILHISTORY_EXPORTWINDOW_HEADER))

    -- MailHistory_ExportWindow_PrevButton
    local exportWindowPrevButton = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_ExportWindow_PrevButton", MailHistory.exportWindow, "ZO_PreviousArrowButton")
	exportWindowPrevButton:SetAnchor(TOP, MailHistory.exportWindow, TOP, -16, 16)
    exportWindowPrevButton:SetHandler("OnClicked", function() MailHistory.GotoExportPage(MailHistory.exportPageNumber - 1) end)
    exportWindowPrevButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SI_MAILHISTORY_EXPORTWINDOW_PREVBUTTON_TOOLTIP)) end)
    exportWindowPrevButton:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)

    -- MailHistory_ExportWindow_NextButton
    local exportWindowNextButton = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_ExportWindow_NextButton", MailHistory.exportWindow, "ZO_NextArrowButton")
	exportWindowNextButton:SetAnchor(TOP, MailHistory.exportWindow, TOP, 16, 16)
    exportWindowNextButton:SetHandler("OnClicked", function() MailHistory.GotoExportPage(MailHistory.exportPageNumber + 1) end)
    exportWindowNextButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SI_MAILHISTORY_EXPORTWINDOW_NEXTBUTTON_TOOLTIP)) end)
    exportWindowNextButton:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)

    -- MailHistory_ExportWindow_CloseButton
    local exportWindowCloseButton = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_ExportWindow_CloseButton", MailHistory.exportWindow, "ZO_CloseButton")
	exportWindowCloseButton:SetAnchor(TOPRIGHT, MailHistory.exportWindow, TOPRIGHT, -16, 16)
    exportWindowCloseButton:SetHandler("OnClicked", function() MailHistory.HideExportWindow() end)

    -- MailHistory_ExportWindow_HeaderDivider
    local exportWindowHeaderDivider = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_ExportWindow_HeaderDivider", MailHistory.exportWindow, "ZO_HorizontalDivider")
    exportWindowHeaderDivider:SetAnchor(TOPLEFT, MailHistory.exportWindow, TOPLEFT, 0, 48)
    exportWindowHeaderDivider:SetAnchor(BOTTOMRIGHT, MailHistory.exportWindow, TOPRIGHT, 0, 56)

    -- MailHistory_ExportWindow_EditBoxBackdrop
    local exportWindowEditBoxBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_ExportWindow_EditBoxBackdrop", MailHistory.exportWindow, "ZO_SingleLineEditBackdrop_Keyboard")
	exportWindowEditBoxBackdrop:SetAnchor(TOPLEFT, MailHistory.exportWindow, TOPLEFT, 16, 60)
    exportWindowEditBoxBackdrop:SetAnchor(BOTTOMRIGHT, MailHistory.exportWindow, BOTTOMRIGHT, -16, -48)

    -- MailHistory_ExportWindow_EditBox
    MailHistory.exportWindowEditBox = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_ExportWindow_EditBox", MailHistory.exportWindow, "ZO_DefaultEditMultiLineForBackdrop")
	MailHistory.exportWindowEditBox:SetAnchor(TOPLEFT, MailHistory.exportWindow, TOPLEFT, 20, 62)
    MailHistory.exportWindowEditBox:SetAnchor(BOTTOMRIGHT, MailHistory.exportWindow, BOTTOMRIGHT, -20, -50)
    MailHistory.exportWindowEditBox:SetEditEnabled(false)
    MailHistory.exportWindowEditBox:SetMaxInputChars(64000)  -- NOTICE: May actually get less, so check using GetMaxInputChars().

    -- MailHistory_ExportWindow_FooterDivider
    local exportWindowFooterDivider = WINDOW_MANAGER:CreateControlFromVirtual("MailHistory_ExportWindow_FooterDivider", MailHistory.exportWindow, "ZO_HorizontalDivider")
    exportWindowFooterDivider:SetAnchor(TOPLEFT, MailHistory.exportWindow, BOTTOMLEFT, 0, -40)
    exportWindowFooterDivider:SetAnchor(BOTTOMRIGHT, MailHistory.exportWindow, BOTTOMRIGHT, 0, -32)

    -- MailHistory_ExportWindow_StatusLabel
    MailHistory.exportWindowStatusLabel = WINDOW_MANAGER:CreateControl("MailHistory_ExportWindow_StatusLabel", MailHistory.exportWindow, CT_LABEL)
    MailHistory.exportWindowStatusLabel:SetAnchor(TOPLEFT, MailHistory.exportWindow, BOTTOMLEFT, 16, -34)
    MailHistory.exportWindowStatusLabel:SetAnchor(BOTTOMRIGHT, MailHistory.exportWindow, BOTTOMRIGHT, -16, -10)
    MailHistory.exportWindowStatusLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    MailHistory.exportWindowStatusLabel:SetFont("ZoFontGame")
    MailHistory.exportWindowStatusLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    MailHistory.exportWindowStatusLabel:SetDrawLayer(DL_TEXT)

end

EVENT_MANAGER:RegisterForEvent(MailHistory.name, EVENT_ADD_ON_LOADED, MailHistory.OnAddOnLoaded)