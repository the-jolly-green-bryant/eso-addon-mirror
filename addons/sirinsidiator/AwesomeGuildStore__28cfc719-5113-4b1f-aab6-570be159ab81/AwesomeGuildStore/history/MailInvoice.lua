local AGS = AwesomeGuildStore

local CONTAINER_NAME = "AwesomeGuildStoreMailSaleInvoiceContainer"
local LINE_NAME_TEMPLATE = "%sLine%d"
local DIVIDER_HEIGHT = 8
local LINE_HEIGHT = 20

local iconMarkup = string.format("|t%u:%u:%s|t", 16, 16, "EsoUI/Art/currency/currency_gold.dds")
local positiveColor = ZO_ColorDef:New("00FF00")
local negativeColor = ZO_ColorDef:New("FF0000")
local neutralColor = ZO_ColorDef:New("FFFFFF")
local SIGN_NEGATIVE = "-"
local SIGN_POSITIVE = "+"
local HELP_ICON_MOUSE_OVER_ALPHA = 1
local HELP_ICON_MOUSE_EXIT_ALPHA = 0.4
local HELP_ICON_SIZE = 23

local gettext = AGS.internal.gettext

local MailInvoice = ZO_InitializingObject:Subclass()
AGS.class.MailInvoice = MailInvoice

function MailInvoice:Initialize()
    self.nextId = 1

    local container = ZO_MailInboxMessagePaneScrollChild:CreateControl(CONTAINER_NAME, CT_CONTROL)
    container:SetAnchor(TOPLEFT, ZO_MailInboxMessageBody, BOTTOMLEFT, 50, 30)
    container:SetAnchor(TOPRIGHT, ZO_MailInboxMessageBody, BOTTOMRIGHT, -50, 30)
    container:SetHidden(true)
    self.container = container
    self.previousLine = container

    local sellValueLabel = GetString(SI_TRADING_HOUSE_POSTING_PRICE_TOTAL):gsub(":", "")
    -- TRANSLATORS: help text for the listing price in the guild store sell mail invoice
    local sellValueTooltipText = gettext("The price the item was listed for")
    self.sellValue = self:CreateLine(sellValueLabel, sellValueTooltipText)

    self:CreateDivider()

    local guildBankLabel = GetString(SI_TRADING_HOUSE_POSTING_TH_CUT)
    -- TRANSLATORS: help text for the tax amount in the guild store sell mail invoice
    local guildBankTooltipText = gettext("The amount that was deposited into the guild bank as tax")
    self.guildBank = self:CreateLine(guildBankLabel, guildBankTooltipText, SIGN_NEGATIVE)

    -- TRANSLATORS: label for the commission line in the guild store sell mail invoice
    local commissionLabel = gettext("Commission")
    -- TRANSLATORS: help text for the commission in the guild store sell mail invoice
    local commissionTooltipText = gettext("The amount that disappeared into the void")
    self.commission = self:CreateLine(commissionLabel, commissionTooltipText, SIGN_NEGATIVE)

    self:CreateDivider()

    local receivedLabel = GetString(SI_MAIL_READ_SENT_GOLD_LABEL):gsub(":", "")
    -- TRANSLATORS: help text for the received gold in the guild store sell mail invoice
    local receivedTooltipText = gettext("The gold attached to this mail")
    self.received = self:CreateLine(receivedLabel, receivedTooltipText)

    self:CreateDivider()

    local listingFeeLabel = GetString(SI_TRADING_HOUSE_POSTING_LISTING_FEE)
    -- TRANSLATORS: help text for the listing fee in the guild store sell mail invoice
    local listingFeeTooltipText = gettext(
        "The fee that was taken from the inventory when the item was listed in the store")
    self.listingFee = self:CreateLine(listingFeeLabel, listingFeeTooltipText, SIGN_NEGATIVE)

    self:CreateDivider()

    local profitLabel = GetString(SI_TRADING_HOUSE_POSTING_PROFIT)
    -- TRANSLATORS: help text for the profit in the guild store sell mail invoice
    local profitTooltipText = gettext("The resulting profit after subtracting all the fees")
    self.profit = self:CreateLine(profitLabel, profitTooltipText)
end

local function SetValue(line, value)
    local valueControl, sign = line.value, line.sign
    if (sign == SIGN_POSITIVE and value ~= 0) then
        valueControl:SetColor(positiveColor:UnpackRGBA())
    elseif (sign == SIGN_NEGATIVE and value ~= 0) then
        valueControl:SetColor(negativeColor:UnpackRGBA())
    else
        valueControl:SetColor(neutralColor:UnpackRGBA())
        sign = ""
    end
    valueControl:SetText(zo_strformat("<<3>><<1>> <<2>>", ZO_CurrencyControl_FormatCurrency(value), iconMarkup,
        sign or ""))
end

function MailInvoice:CreateLine(label, tooltipText, sign)
    local line = self:CreateLineContainer(LINE_HEIGHT)

    local labelControl = line:CreateControl("$(parent)Label", CT_LABEL)
    labelControl:SetFont("ZoFontWinH4")
    labelControl:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    labelControl:SetAnchor(TOPLEFT, line, TOPLEFT, HELP_ICON_SIZE, 0)
    labelControl:SetText(zo_strformat("<<1>>:", label))

    local valueControl = line:CreateControl("$(parent)Value", CT_LABEL)
    valueControl:SetFont("ZoFontWinH4")
    valueControl:SetColor(neutralColor:UnpackRGBA())
    valueControl:SetAnchor(TOPRIGHT, line, TOPRIGHT, 0, 0)
    line.sign = sign
    line.value = valueControl

    if tooltipText then
        local helpControl = line:CreateControl("$(parent)Help", CT_TEXTURE)
        helpControl:SetTexture("EsoUI/Art/miscellaneous/help_icon.dds")
        helpControl:SetDimensions(HELP_ICON_SIZE, HELP_ICON_SIZE)
        helpControl:SetColor(neutralColor:UnpackRGBA())
        helpControl:SetAlpha(HELP_ICON_MOUSE_EXIT_ALPHA)
        helpControl:SetAnchor(RIGHT, labelControl, LEFT, 0, 0)
        helpControl:SetMouseEnabled(true)
        helpControl:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip, helpControl, BOTTOMLEFT, 0, -2, TOPLEFT)
            SetTooltipText(InformationTooltip, tooltipText)
            helpControl:SetAlpha(HELP_ICON_MOUSE_OVER_ALPHA)
        end)
        helpControl:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
            helpControl:SetAlpha(HELP_ICON_MOUSE_EXIT_ALPHA)
        end)
    end

    line.SetValue = SetValue
    return line
end

function MailInvoice:CreateDivider()
    local line = self:CreateLineContainer(DIVIDER_HEIGHT)
    local name = line:GetName() .. "Divider"
    local divider = line:CreateControl(name, CT_LINE)
    divider:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
    divider:SetAnchor(TOPLEFT, line, LEFT, 0, 14)
    divider:SetAnchor(BOTTOMRIGHT, line, RIGHT, 0, 14)
    divider:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
end

function MailInvoice:CreateLineContainer(height)
    local nextId = self.nextId
    self.nextId = nextId + 1

    local name = string.format(LINE_NAME_TEMPLATE, CONTAINER_NAME, nextId)
    local offset = (nextId == 1 and 0 or height)

    local line = self.container:CreateControl(name, CT_CONTROL)
    line:SetAnchor(TOPLEFT, self.previousLine, TOPLEFT, 0, offset)
    line:SetAnchor(TOPRIGHT, self.previousLine, TOPRIGHT, 0, offset)
    line:SetHeight(height)
    self.previousLine = line

    return line
end

function MailInvoice:Show(saleData)
    self.sellValue:SetValue(saleData.price)
    self.guildBank:SetValue(saleData.tax)
    self.commission:SetValue(saleData.houseCut - saleData.tax)
    self.received:SetValue(saleData.profit + saleData.listingFee)
    self.listingFee:SetValue(saleData.listingFee)
    self.profit:SetValue(saleData.profit)
    self.container:SetHidden(false)
end

function MailInvoice:Hide()
    self.container:SetHidden(true)
end
