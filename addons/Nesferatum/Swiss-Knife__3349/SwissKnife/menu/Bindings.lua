local SK = SwissKnife
local KS = KEYBIND_STRIP

local SKMailerButtonGroup = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
        name = GetString(SI_BINDING_NAME_SK_RECEIPT_MAIL),
        keybind = "SK_RECEIPT_MAIL",
        callback = function() mailerSK:ReceiptAllMails() end,
        visible = function() return not SK.savedVars.isAutomaticModeReceiptMail end,
        disable = function() return SK.savedVars.isAutomaticModeReceiptMail end,
    },
}

local SKTransferButtonGroup = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
    {
        name = GetString(SI_BINDING_NAME_SK_BANK),
        keybind = "SK_BANK",
        callback = function() SKBT:Open() end,
    },
}

local function onMailboxOpenKeybindStrip()
    if not KS:HasKeybindButtonGroup(SKMailerButtonGroup) then
        KS:AddKeybindButtonGroup(SKMailerButtonGroup)
    end
end

local function onMailboxCloseKeybindStrip()
    if KS:HasKeybindButtonGroup(SKMailerButtonGroup) then
        KS:RemoveKeybindButtonGroup(SKMailerButtonGroup)
    end
end

local function onGuildBankOpenKeybindStrip()
    if not KS:HasKeybindButtonGroup(SKTransferButtonGroup) then
        KS:AddKeybindButtonGroup(SKTransferButtonGroup)
    end
end

local function onGuildBankCloseKeybindStrip()
    if KS:HasKeybindButtonGroup(SKTransferButtonGroup) then
        KS:RemoveKeybindButtonGroup(SKTransferButtonGroup)
    end
end

-- Export
SK.Bindings = {
    onMailboxOpenKeybindStrip = onMailboxOpenKeybindStrip,
    onMailboxCloseKeybindStrip = onMailboxCloseKeybindStrip,
    onGuildBankOpenKeybindStrip = onGuildBankOpenKeybindStrip,
    onGuildBankCloseKeybindStrip = onGuildBankCloseKeybindStrip
}
