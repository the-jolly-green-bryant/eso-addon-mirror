local AGS = AwesomeGuildStore

AGS.internal.InitializeAugmentedMails = function(saveData)
    if not saveData.augementMails then return end
    local RegisterForEvent = AGS.internal.RegisterForEvent
    local WrapFunction = AGS.internal.WrapFunction
    local AcquireLoadingIcon = AGS.class.LoadingIcon.Acquire
    local gettext = AGS.internal.gettext
    local logger = AGS.internal.logger

    local neutralColor = ZO_ColorDef:New("FFFFFF")
    saveData.mailAugmentationData = saveData.mailAugmentationData or {}
    local guildHistory = AGS.class.GuildHistoryHelper:New(saveData)

    local mailInvoice
    local loadingLabel, loadingSpinner, openButton
    local messageControl = MAIL_INBOX.messageControl
    local fromControl = GetControl(messageControl, "From")
    local subjectControl = GetControl(messageControl, "Subject")
    local expiresControl = GetControl(messageControl, "Expires")
    local receivedControl = GetControl(messageControl, "Received")
    local bodyControl = GetControl(messageControl, "Body")

    -- TRANSLATORS: this is used to find guild store sell mails. it has to be exactly the same as the subject of the ingame mails, otherwise the detection will fail
    local ITEM_SOLD_SUBJECT = gettext("Item Sold")
    local function IsGuildStoreMail(dataTable)
        return dataTable.fromSystem and dataTable.subject == ITEM_SOLD_SUBJECT
    end

    local function GetMailEventData(mailId)
        local idString = Id64ToString(mailId)
        return saveData.mailAugmentationData[idString]
    end

    local function SetMailEventData(mailId, eventData)
        local idString = Id64ToString(mailId)
        saveData.mailAugmentationData[idString] = eventData
    end

    RegisterForEvent(EVENT_MAIL_REMOVED, function(_, mailId)
        logger:Debug("Remove mail data for %s", Id64ToString(mailId))
        SetMailEventData(mailId, nil)
    end)

    RegisterForEvent(EVENT_MAIL_OPEN_MAILBOX, function()
        local existingMailIds = {}
        local hasMail = false
        for mailId in ZO_GetNextMailIdIter do
            hasMail = true
            existingMailIds[Id64ToString(mailId)] = true
        end
        if not hasMail then return end

        for mailIdString in pairs(saveData.mailAugmentationData) do
            if not existingMailIds[mailIdString] then
                logger:Debug("Clean up mail data for %s", mailIdString)
                saveData.mailAugmentationData[mailIdString] = nil
            end
        end
    end)

    local function AugmentMailData(dataTable, eventData)
        dataTable.fromStore = true
        if eventData then
            dataTable.senderDisplayName = eventData.guildName
            dataTable.eventData = eventData
            dataTable.eventDataPending = nil
            return true
        elseif dataTable.skipNextRequest then
            dataTable.skipNextRequest = nil
            return true
        else
            dataTable.eventDataPending = true
            return false
        end
    end

    local function RefreshShownMail(mailData)
        if not AreId64sEqual(mailData.mailId, MAIL_INBOX.mailId) then return end
        ZO_MailInboxShared_PopulateMailData(mailData, mailData.mailId)
        ZO_MailInboxShared_UpdateInbox(mailData, fromControl, subjectControl, expiresControl, receivedControl,
            bodyControl)
    end

    local function PopulateMailData(dataTable)
        if not IsGuildStoreMail(dataTable) then return end
        local eventData = GetMailEventData(dataTable.mailId)
        if AugmentMailData(dataTable, eventData) then return end

        local mailTime = GetTimeStamp() - dataTable.secsSinceReceived
        local attachedMoney = dataTable.attachedMoney
        guildHistory:FindEventData(dataTable.mailId, mailTime, attachedMoney):Then(function(eventData)
            SetMailEventData(dataTable.mailId, eventData)
            AugmentMailData(dataTable, eventData)
            RefreshShownMail(dataTable)
        end, function()
            dataTable.eventDataPending = false
            dataTable.skipNextRequest = true
            RefreshShownMail(dataTable)
        end)
    end

    local function GetOrCreateLoadingControls()
        if not loadingLabel then
            loadingLabel = ZO_MailInboxMessagePaneScrollChild:CreateControl("AwesomeGuildStoreMailSaleInvoiceLoading",
                CT_LABEL)
            loadingLabel:SetAnchor(TOP, ZO_MailInboxMessageBody, BOTTOM, 0, 30)
            loadingLabel:SetFont("ZoFontWinH4")
            loadingLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
            loadingLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            loadingSpinner = AcquireLoadingIcon()
            loadingSpinner:SetParent(loadingLabel)
            loadingSpinner:ClearAnchors()
            loadingSpinner:SetAnchor(RIGHT, loadingLabel, LEFT, -20, 0)
            openButton = CreateControlFromVirtual("AwesomeGuildStoreMailSaleOpenHistoryButton",
                ZO_MailInboxMessagePaneScrollChild, "ZO_DefaultButton")
            openButton:SetAnchor(TOP, loadingLabel, BOTTOM, 0, 10)
            -- TRANSLATORS: label for the open history button in guild store sell mails where the invoice can not be shown due to lack of data
            openButton:SetText(gettext("Open History"))
            openButton:SetWidth(200)
            openButton:SetHandler("OnMouseUp", function(control, button, isInside)
                if button == MOUSE_BUTTON_INDEX_LEFT and isInside then
                    MAIN_MENU_KEYBOARD:ShowScene("guildHistory")
                end
            end)
        end
        return loadingLabel, loadingSpinner, openButton
    end

    local disabledMessage
    if LibHistoire:IsGuildHistorySystemDisabled() then
        disabledMessage = "\n" ..
            ZO_ERROR_COLOR:Colorize(gettext(
                "The guild history was disabled by ZOS.\nSome transaction data may be unavailable."))
    end

    local function ShowLoading()
        local label, spinner, openButton = GetOrCreateLoadingControls()
        local message = gettext("Loading transaction data...")
        if disabledMessage then
            message = message .. disabledMessage
        end
        label:SetText(message)
        label:SetHidden(false)
        spinner:Show()
        openButton:SetHidden(false)
    end

    local function ShowNotFound()
        local label, spinner, openButton = GetOrCreateLoadingControls()
        local message = gettext("Could not find transaction data.")
        if disabledMessage then
            message = message .. disabledMessage
        end
        label:SetText(message)
        label:SetHidden(false)
        spinner:Hide()
        openButton:SetHidden(false)
    end

    local function HideLoading()
        if loadingLabel then
            loadingLabel:SetHidden(true)
            loadingSpinner:Hide()
            openButton:SetHidden(true)
        end
    end

    local function UpdateInbox(mailData)
        if saveData.mailAugmentationShowInvoice and mailData.fromStore and mailData.eventData then
            if not mailInvoice then
                mailInvoice = AGS.class.MailInvoice:New()
            end
            mailInvoice:Show(mailData.eventData)
        elseif mailInvoice then
            mailInvoice:Hide()
        end

        if mailData.eventDataPending then
            ShowLoading()
        elseif mailData.eventDataPending == false then
            ShowNotFound()
        else
            HideLoading()
        end
    end

    local function ReadMail(originalReadMail, mailId)
        local data = GetMailEventData(mailId)
        if not data then return originalReadMail(mailId) end

        local buyerLink = neutralColor:Colorize(ZO_LinkHandler_CreateDisplayNameLink(data.buyerName)):gsub("[%[%]]", "")
        local itemCount = neutralColor:Colorize(data.quantity .. "x")
        local sellPrice = ZO_Currency_FormatPlatform(CURT_MONEY, data.price, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
        -- TRANSLATORS: Mail body for item sold mails from the guild store. <<t:1>> is replaced by the itemlink, <<2>> by the item count, <<3>> by the buyer name and <<4>> by the sell price. e.g. You sold 1 Rosin to sirinsidiator for 5000g.
        return gettext("You sold <<2>> <<t:1>> to <<3>> for <<4>>.", data.itemLink, itemCount, buyerLink, sellPrice)
    end

    SecurePostHook("ZO_MailInboxShared_PopulateMailData", PopulateMailData)
    SecurePostHook("ZO_MailInboxShared_UpdateInbox", UpdateInbox)
    WrapFunction("ReadMail", ReadMail)
end
