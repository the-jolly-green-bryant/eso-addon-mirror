GoldMailHelper = {
    name = "GoldMailHelper",
    version = "1.2.0",
    defaults = {
        recipient = "@iDRKH",
        useAllGold = true,
        amount = 1000,
        subject = "Gold",
        body = "",
        autoSendOnLoad = true,
    },
}

local GMH = GoldMailHelper
local EM = EVENT_MANAGER

local function ToNumber(value, fallback)
    local n = tonumber(value)
    if not n then return fallback end
    n = zo_floor(zo_max(n, 0))
    return n
end

function GMH:Log(msg)
    local s = string.format("|cD7B46A[%s]|r %s", self.name, tostring(msg))
    if CHAT_SYSTEM then CHAT_SYSTEM:AddMessage(s) else d(s) end
end

function GMH:IsMailSceneOpen()
    return SCENE_MANAGER and SCENE_MANAGER:IsShowing("mailSend") and MAIL_SEND ~= nil
end

function GMH:GetRecipient()
    return (self.saved.recipient or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

function GMH:GetCurrentCharacterGold()
    if GetCurrencyAmount then
        return GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    end
    return 0
end

function GMH:GetAmountToSend()
    if self.saved.useAllGold then
        return zo_max(0, self:GetCurrentCharacterGold())
    end
    return ToNumber(self.saved.amount, self.defaults.amount)
end

function GMH:FillCurrentMail()
    if not self:IsMailSceneOpen() then
        self:Log("Open the send mail window first.")
        return false
    end

    local recipient = self:GetRecipient()
    local amount = self:GetAmountToSend()
    local subject = self.saved.subject or ""
    local body = self.saved.body or ""

    if recipient == "" then
        self:Log("Set the recipient first in Settings > Addons > GoldMailHelper.")
        return false
    end

    if amount <= 0 then
        self:Log("This character has no gold to attach.")
        return false
    end

    local ok, err = pcall(function()
        if MAIL_SEND.to then MAIL_SEND.to:SetText(recipient) end
        if MAIL_SEND.subject then MAIL_SEND.subject:SetText(subject) end
        if MAIL_SEND.body then MAIL_SEND.body:SetText(body) end
        if MAIL_SEND.AttachMoney and MAIL_SEND.sendCurrency then
            MAIL_SEND:AttachMoney(MAIL_SEND.sendCurrency, amount)
        end
    end)

    if not ok then
        self:Log("Could not fill the current mail: " .. tostring(err))
        return false
    end

    self:Log(string.format("Filled mail to %s with %d gold.", recipient, amount))
    return true
end

function GMH:TrySendCurrentMail()
    if not self:IsMailSceneOpen() then
        return false
    end

    if not self:FillCurrentMail() then
        return false
    end

    local ok, err = pcall(function()
        if MAIL_SEND and MAIL_SEND.Send then
            MAIL_SEND:Send()
        elseif AttemptSendMail then
            AttemptSendMail()
        else
            error("No supported send function found")
        end
    end)

    if not ok then
        self:Log("Auto-send failed: " .. tostring(err))
        return false
    end

    self.didAutoSend = true
    self:Log("Auto-send triggered.")
    return true
end

function GMH:EnsureAutoSendHook()
    if self.autoHookRegistered then return end
    if not MAIL_SEND_SCENE then return end

    MAIL_SEND_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING and self.saved.autoSendOnLoad and not self.didAutoSend then
            zo_callLater(function()
                self:TrySendCurrentMail()
            end, 400)
        end
    end)

    self.autoHookRegistered = true
end

function GMH:ShowStatus()
    self:Log(string.format("Recipient: %s | Mode: %s | Gold: %d | AutoSend: %s", self:GetRecipient(), self.saved.useAllGold and "all" or "fixed", self:GetAmountToSend(), tostring(self.saved.autoSendOnLoad)))
end

function GMH:RegisterSettingsMenu()
    local LAM = LibStub and LibStub("LibAddonMenu-2.0", true)
    if not LAM then
        self:Log("Settings menu unavailable: LibAddonMenu-2.0 not loaded.")
        return
    end

    local panelData = {
        type = "panel",
        name = self.name,
        displayName = "Gold Mail Helper",
        author = "Codex",
        version = self.version,
        slashCommand = "/goldmailsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "header",
            name = "Gold Mail",
            width = "full",
        },
        {
            type = "description",
            text = "Targets @iDRKH and can attach all carried gold. Auto-send runs the first time the send-mail window opens after loading the add-on.",
            width = "full",
        },
        {
            type = "editbox",
            name = "Recipient Account",
            tooltip = "Use the ESO account format, for example @iDRKH.",
            getFunc = function() return GMH.saved.recipient end,
            setFunc = function(value) GMH.saved.recipient = value end,
            isMultiline = false,
            width = "full",
            default = GMH.defaults.recipient,
        },
        {
            type = "checkbox",
            name = "Send All Character Gold",
            tooltip = "When enabled, the add-on uses the full gold amount carried by the current character.",
            getFunc = function() return GMH.saved.useAllGold end,
            setFunc = function(value) GMH.saved.useAllGold = value end,
            width = "full",
            default = GMH.defaults.useAllGold,
        },
        {
            type = "checkbox",
            name = "Auto Send On Load",
            tooltip = "When enabled, the first time you open Send Mail after loading the add-on it will try to send automatically.",
            getFunc = function() return GMH.saved.autoSendOnLoad end,
            setFunc = function(value) GMH.saved.autoSendOnLoad = value end,
            width = "full",
            default = GMH.defaults.autoSendOnLoad,
            warning = "Use carefully. It will attempt to send without a final manual click once the send-mail window opens.",
        },
        {
            type = "editbox",
            name = "Fixed Gold Amount",
            tooltip = "Used only when 'Send All Character Gold' is disabled.",
            getFunc = function() return tostring(ToNumber(GMH.saved.amount, GMH.defaults.amount)) end,
            setFunc = function(value) GMH.saved.amount = ToNumber(value, GMH.defaults.amount) end,
            isMultiline = false,
            width = "half",
            default = tostring(GMH.defaults.amount),
        },
        {
            type = "editbox",
            name = "Subject",
            tooltip = "Optional mail subject.",
            getFunc = function() return GMH.saved.subject end,
            setFunc = function(value) GMH.saved.subject = value end,
            isMultiline = false,
            width = "half",
            default = GMH.defaults.subject,
        },
        {
            type = "editbox",
            name = "Body",
            tooltip = "Optional mail body.",
            getFunc = function() return GMH.saved.body end,
            setFunc = function(value) GMH.saved.body = value end,
            isMultiline = true,
            width = "full",
            default = GMH.defaults.body,
        },
        {
            type = "button",
            name = "Fill Current Mail",
            tooltip = "Open a mailbox send window first, then press this to fill recipient and gold.",
            func = function() GMH:FillCurrentMail() end,
            width = "half",
        },
        {
            type = "button",
            name = "Send Now",
            tooltip = "Open a mailbox send window first, then press this to fill and try to send immediately.",
            func = function() GMH:TrySendCurrentMail() end,
            width = "half",
            warning = "This attempts to send immediately.",
        },
        {
            type = "button",
            name = "Show Status",
            tooltip = "Print the current recipient and amount mode in chat.",
            func = function() GMH:ShowStatus() end,
            width = "full",
        },
    }

    LAM:RegisterAddonPanel(self.name, panelData)
    LAM:RegisterOptionControls(self.name, optionsTable)
end

local function SlashFill()
    GMH:FillCurrentMail()
end

local function SlashSend()
    GMH:TrySendCurrentMail()
end

local function SlashStatus()
    GMH:ShowStatus()
end

function GMH:OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= self.name then return end
    EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    self.saved = ZO_SavedVars:NewAccountWide("GoldMailHelperSaved", 1, nil, self.defaults)
    self.saved.amount = ToNumber(self.saved.amount, self.defaults.amount)
    if self.saved.useAllGold == nil then self.saved.useAllGold = true end
    if self.saved.autoSendOnLoad == nil then self.saved.autoSendOnLoad = true end
    if not self.saved.recipient or self.saved.recipient == "" then
        self.saved.recipient = self.defaults.recipient
    end

    SLASH_COMMANDS["/goldmail"] = SlashFill
    SLASH_COMMANDS["/goldmailsend"] = SlashSend
    SLASH_COMMANDS["/goldmailstatus"] = SlashStatus
    SLASH_COMMANDS["/goldmailsettings"] = function() end

    self:RegisterSettingsMenu()
    self:EnsureAutoSendHook()
    self:Log("Loaded. Recipient is @iDRKH. Auto-send will try on the first send-mail window open.")
end

EM:RegisterForEvent(GMH.name, EVENT_ADD_ON_LOADED, function(...) GMH:OnAddOnLoaded(...) end)
