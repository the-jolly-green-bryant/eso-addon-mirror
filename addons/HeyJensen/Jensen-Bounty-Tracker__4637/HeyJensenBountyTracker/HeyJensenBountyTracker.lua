HeyJensenBountyTracker = {}
local HJBT = HeyJensenBountyTracker

HJBT.name = "HeyJensenBountyTracker"
HJBT.displayName = "Hey Jensen Bounty Tracker"
HJBT.version = "1.0.2"
HJBT.boardTexture = "HeyJensenBountyTracker/media/jensen_bounty_board.dds"

HJBT.defaults =
{
    settings =
    {
        adminAccount = "@Hey-Jensen",
        bankAccount = "@Hey-Jensen",
        minimumDuelSeconds = 10,
    },
    bounties =
    {
        active = {},
        history = {},
        claims = {},
    },
    lastClaim = nil,
    activeDuel = nil,
}

local function HJBTChat(message)
    d("|cFFDD66Hey Jensen Bounty Tracker:|r " .. tostring(message))
end

function HJBT:GetNow()
    if GetTimeStamp ~= nil then
        return GetTimeStamp()
    end

    return 0
end

function HJBT:NormalizeAccountName(value)
    local account = tostring(value or "")
    account = string.gsub(account, "|H.-|h(.-)|h", "%1")
    account = string.gsub(account, "%s+", "")
    account = string.gsub(account, "^@+", "")

    if account == "" then
        return ""
    end

    return "@" .. account
end

function HJBT:NormalizeAmount(value)
    local amountText = tostring(value or "")
    amountText = string.gsub(amountText, ",", "")
    amountText = string.gsub(amountText, "%D", "")
    local amount = tonumber(amountText or "0") or 0

    if amount < 0 then
        amount = 0
    end

    return zo_floor(amount)
end

function HJBT:FormatGold(amount)
    amount = self:NormalizeAmount(amount)
    local text = tostring(amount)
    local formatted = text

    while true do
        local nextText, changes = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        formatted = nextText

        if changes == 0 then
            break
        end
    end

    return formatted
end

function HJBT:GetLocalAccount()
    if GetDisplayName ~= nil then
        return GetDisplayName()
    end

    return "@Unknown"
end

function HJBT:IsAdminAccount(value)
    local admin = string.lower(self:NormalizeAccountName(self.saved.settings.adminAccount or "@Hey-Jensen"))
    local normalized = string.lower(self:NormalizeAccountName(value))
    return admin == normalized
end

function HJBT:IsBountyAdmin(fromName, fromDisplayName)
    return self:IsAdminAccount(fromName) or self:IsAdminAccount(fromDisplayName)
end

function HJBT:SetBounty(targetAccount, amount, sourceText)
    targetAccount = self:NormalizeAccountName(targetAccount)
    amount = self:NormalizeAmount(amount)

    if targetAccount == "" or amount <= 0 then
        return false
    end

    self.saved.bounties.active[targetAccount] =
    {
        targetAccount = targetAccount,
        amount = amount,
        updatedAt = self:GetNow(),
        sourceText = tostring(sourceText or ""),
    }

    table.insert(self.saved.bounties.history,
    {
        action = "set",
        targetAccount = targetAccount,
        amount = amount,
        timestamp = self:GetNow(),
        sourceText = tostring(sourceText or ""),
    })

    self:RefreshWindow()
    HJBTChat("Bounty board updated: " .. targetAccount .. " is worth " .. self:FormatGold(amount) .. " gold.")
    return true
end

function HJBT:RemoveBounty(targetAccount, sourceText)
    targetAccount = self:NormalizeAccountName(targetAccount)

    if targetAccount == "" then
        return false
    end

    self.saved.bounties.active[targetAccount] = nil

    table.insert(self.saved.bounties.history,
    {
        action = "remove",
        targetAccount = targetAccount,
        amount = 0,
        timestamp = self:GetNow(),
        sourceText = tostring(sourceText or ""),
    })

    self:RefreshWindow()
    HJBTChat("Bounty removed from board: " .. targetAccount)
    return true
end

function HJBT:GetSortedBounties()
    local list = {}

    for targetAccount, bounty in pairs(self.saved.bounties.active) do
        table.insert(list, bounty)
    end

    table.sort(list, function(a, b)
        if a.amount == b.amount then
            return tostring(a.targetAccount) < tostring(b.targetAccount)
        end

        return a.amount > b.amount
    end)

    return list
end

function HJBT:GetBountyBoardText()
    local list = self:GetSortedBounties()

    if #list == 0 then
        return "No active bounties saved on this client yet.\n\nBounties update when this addon sees a bounty message from " .. tostring(self.saved.settings.adminAccount or "@Hey-Jensen") .. " in chat."
    end

    local text = ""

    for index = 1, zo_min(18, #list) do
        local bounty = list[index]
        text = text .. tostring(index) .. ". " .. bounty.targetAccount .. "  " .. self:FormatGold(bounty.amount) .. " gold\n"
    end

    return text
end

function HJBT:ParseBountyBroadcast(message)
    local original = tostring(message or "")
    local lower = string.lower(original)

    if not string.find(lower, "bounty") then
        return nil
    end

    local paidTarget = string.match(original, "[Pp]aid:%s*(@?[%w_%-]+)")
    local removeTarget = string.match(original, "[Rr]emove:%s*(@?[%w_%-]+)")

    if paidTarget ~= nil then
        return "remove", paidTarget, 0
    end

    if removeTarget ~= nil then
        return "remove", removeTarget, 0
    end

    if string.find(lower, "bounty paid") or string.find(lower, "bounty claimed") or string.find(lower, "remove bounty") then
        local target = string.match(original, "(@[%w_%-]+)")

        if target ~= nil then
            return "remove", target, 0
        end
    end

    local target, amount = string.match(original, "[Bb]ounty%s+for%s+(@?[%w_%-]+)%s+is%s+([%d,]+)")
    if target ~= nil and amount ~= nil then
        return "set", target, amount
    end

    target, amount = string.match(original, "[Hh]ey%s+[Jj]ensen%s+[Bb]ounty:%s+(@?[%w_%-]+)%s+is%s+([%d,]+)")
    if target ~= nil and amount ~= nil then
        return "set", target, amount
    end

    target, amount = string.match(original, "[Rr]anked%s+[Dd]uels%s+[Bb]ounty:%s+(@?[%w_%-]+)%s+is%s+([%d,]+)")
    if target ~= nil and amount ~= nil then
        return "set", target, amount
    end

    target, amount = string.match(original, "[Bb]ounty:%s+(@?[%w_%-]+)%s+is%s+([%d,]+)")
    if target ~= nil and amount ~= nil then
        return "set", target, amount
    end

    target, amount = string.match(original, "[Bb]ounty%s+(@?[%w_%-]+)%s+([%d,]+)")
    if target ~= nil and amount ~= nil then
        return "set", target, amount
    end

    return nil
end

function HJBT:OnChatMessage(channelType, fromName, text, isCustomerService, fromDisplayName)
    if self:IsBountyAdmin(fromName, fromDisplayName) ~= true then
        return
    end

    local action, target, amount = self:ParseBountyBroadcast(text)

    if action == "set" then
        self:SetBounty(target, amount, text)
    elseif action == "remove" then
        self:RemoveBounty(target, text)
    end
end

function HJBT:OpenBountyMail(targetAccount, amount)
    targetAccount = self:NormalizeAccountName(targetAccount)
    amount = self:NormalizeAmount(amount)

    if targetAccount == "" or amount <= 0 then
        HJBTChat("Enter a bounty target and gold amount first.")
        return
    end

    local bankAccount = self.saved.settings.bankAccount or "@Hey-Jensen"
    local subject = "BOUNTY " .. targetAccount .. " " .. tostring(amount)
    local body = "Bounty target: " .. targetAccount .. "\nGold amount: " .. self:FormatGold(amount) .. "\nPlease attach the gold manually before sending."

    if SCENE_MANAGER ~= nil then
        SCENE_MANAGER:Show("mailSend")
    end

    if zo_callLater ~= nil then
        zo_callLater(function()
            if ZO_MailSendToField ~= nil and ZO_MailSendToField.SetText ~= nil then
                ZO_MailSendToField:SetText(bankAccount)
            end

            if ZO_MailSendSubjectField ~= nil and ZO_MailSendSubjectField.SetText ~= nil then
                ZO_MailSendSubjectField:SetText(subject)
            end

            if ZO_MailSendBodyField ~= nil and ZO_MailSendBodyField.SetText ~= nil then
                ZO_MailSendBodyField:SetText(body)
            end
        end, 250)
    end

    HJBTChat("Mail opened for bounty deposit. Send to " .. bankAccount .. " and attach " .. self:FormatGold(amount) .. " gold manually.")
end

function HJBT:OpenZoneAnnouncement(targetAccount, amount)
    if self:IsAdminAccount(self:GetLocalAccount()) ~= true then
        HJBTChat("Only " .. tostring(self.saved.settings.adminAccount or "@Hey-Jensen") .. " should broadcast official bounty updates.")
        return
    end

    targetAccount = self:NormalizeAccountName(targetAccount)
    amount = self:NormalizeAmount(amount)

    if targetAccount == "" or amount <= 0 then
        HJBTChat("Enter a bounty target and gold amount first.")
        return
    end

    StartChatInput("/z Hey Jensen Bounty: " .. targetAccount .. " is " .. tostring(amount) .. " gold.")
    HJBTChat("Official bounty broadcast is ready. Press Enter to send it in zone chat.")
end

function HJBT:OpenRemoveAnnouncement(targetAccount)
    if self:IsAdminAccount(self:GetLocalAccount()) ~= true then
        HJBTChat("Only " .. tostring(self.saved.settings.adminAccount or "@Hey-Jensen") .. " should broadcast official bounty updates.")
        return
    end

    targetAccount = self:NormalizeAccountName(targetAccount)

    if targetAccount == "" then
        HJBTChat("Enter a bounty target first.")
        return
    end

    StartChatInput("/z Hey Jensen Bounty Remove: " .. targetAccount)
    HJBTChat("Bounty removal broadcast is ready. Press Enter to send it in zone chat.")
end

function HJBT:CreateLabel(parent, name, text, x, y, width, height, font, r, g, b, a)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    label:SetDimensions(width, height)
    label:SetFont(font or "ZoFontGame")
    label:SetText(text or "")
    label:SetColor(r or 1, g or 0.92, b or 0.76, a or 1)
    return label
end

function HJBT:CreateButton(parent, name, text, x, y, width, height, callback)
    local button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    button:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    button:SetDimensions(width, height)
    button:SetFont("ZoFontGameBold")
    button:SetText(text)
    button:SetNormalFontColor(1, 0.86, 0.35, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    button:SetHandler("OnClicked", callback)
    return button
end

function HJBT:CreateEditBox(parent, name, x, y, width, height, defaultText)
    local edit = WINDOW_MANAGER:CreateControl(name, parent, CT_EDITBOX)
    edit:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    edit:SetDimensions(width, height)
    edit:SetFont("ZoFontGame")
    edit:SetText(defaultText or "")
    edit:SetMaxInputChars(64)
    edit:SetMouseEnabled(true)
    edit:SetEditEnabled(true)
    edit:SetMultiLine(false)
    return edit
end

function HJBT:GetWindowTarget()
    if self.window ~= nil and self.window.targetEdit ~= nil then
        return self.window.targetEdit:GetText()
    end

    return ""
end

function HJBT:GetWindowAmount()
    if self.window ~= nil and self.window.amountEdit ~= nil then
        return self.window.amountEdit:GetText()
    end

    return ""
end


function HJBT:CleanCodeName(value)
    local clean = tostring(value or "")
    clean = string.gsub(clean, "@", "")
    clean = string.upper(clean)
    clean = string.gsub(clean, "[^A-Z0-9]", "")
    return clean
end

function HJBT:SimpleChecksum(payload)
    local hash = 7

    for i = 1, string.len(payload) do
        hash = (hash * 31 + string.byte(payload, i)) % 1000000
    end

    return hash
end

function HJBT:GenerateClaimCode(killerAccount, targetAccount, amount, timestamp)
    local killerClean = self:CleanCodeName(killerAccount)
    local targetClean = self:CleanCodeName(targetAccount)
    local amountClean = tostring(self:NormalizeAmount(amount))
    local timeClean = tostring(timestamp or self:GetNow())
    local payload = "HJBTCLAIM|" .. timeClean .. "|" .. killerClean .. "|" .. targetClean .. "|" .. amountClean
    local code = self:SimpleChecksum(payload) % 100000
    return string.format("%05d", code)
end

function HJBT:ValidateClaimCode(killerAccount, targetAccount, amount, timestamp, code)
    local expected = self:GenerateClaimCode(killerAccount, targetAccount, amount, timestamp)
    return tostring(expected) == tostring(code or "")
end

function HJBT:FindBountyForOpponent(opponentCharacterName, opponentDisplayName)
    local display = self:NormalizeAccountName(opponentDisplayName)
    local character = self:NormalizeAccountName(opponentCharacterName)

    if display ~= "" and self.saved.bounties.active[display] ~= nil then
        return self.saved.bounties.active[display]
    end

    if character ~= "" and self.saved.bounties.active[character] ~= nil then
        return self.saved.bounties.active[character]
    end

    return nil
end

function HJBT:BuildClaimMailBody(claim)
    return "Bounty claim verification\n" ..
        "Killer: " .. tostring(claim.killerAccount) .. "\n" ..
        "Target: " .. tostring(claim.targetAccount) .. "\n" ..
        "Bounty: " .. tostring(self:FormatGold(claim.amount)) .. " gold\n" ..
        "Claim Code: " .. tostring(claim.code) .. "\n" ..
        "Timestamp: " .. tostring(claim.timestamp) .. "\n" ..
        "Duel Seconds: " .. tostring(claim.durationSeconds or 0) .. "\n\n" ..
        "Jensen can verify with:\n" ..
        "/hjb verify " .. tostring(claim.killerAccount) .. " " .. tostring(claim.targetAccount) .. " " .. tostring(claim.amount) .. " " .. tostring(claim.code) .. " " .. tostring(claim.timestamp)
end

function HJBT:OpenClaimMail(claim)
    claim = claim or self.saved.lastClaim

    if claim == nil then
        HJBTChat("No bounty claim is saved yet.")
        return
    end

    local bankAccount = self.saved.settings.bankAccount or "@Hey-Jensen"
    local subject = "BOUNTY CLAIM " .. tostring(claim.targetAccount) .. " " .. tostring(claim.code)
    local body = self:BuildClaimMailBody(claim)

    if SCENE_MANAGER ~= nil then
        SCENE_MANAGER:Show("mailSend")
    end

    if zo_callLater ~= nil then
        zo_callLater(function()
            if ZO_MailSendToField ~= nil and ZO_MailSendToField.SetText ~= nil then
                ZO_MailSendToField:SetText(bankAccount)
            end

            if ZO_MailSendSubjectField ~= nil and ZO_MailSendSubjectField.SetText ~= nil then
                ZO_MailSendSubjectField:SetText(subject)
            end

            if ZO_MailSendBodyField ~= nil and ZO_MailSendBodyField.SetText ~= nil then
                ZO_MailSendBodyField:SetText(body)
            end
        end, 250)
    end

    HJBTChat("Bounty claim mail opened. Send it to " .. bankAccount .. " for review.")
end

function HJBT:SaveBountyClaim(targetAccount, amount, durationSeconds)
    local killerAccount = self:GetLocalAccount()
    local timestamp = self:GetNow()
    local code = self:GenerateClaimCode(killerAccount, targetAccount, amount, timestamp)

    local claim =
    {
        killerAccount = killerAccount,
        targetAccount = targetAccount,
        amount = self:NormalizeAmount(amount),
        timestamp = timestamp,
        code = code,
        durationSeconds = durationSeconds or 0,
    }

    self.saved.lastClaim = claim
    table.insert(self.saved.bounties.claims, claim)

    HJBTChat("Bounty claim created: " .. killerAccount .. " defeated " .. targetAccount .. " for " .. self:FormatGold(amount) .. " gold. Code: " .. code)
    d("Use /hjb claim to open a mail to @Hey-Jensen with the claim code.")
    self:RefreshWindow()
    self:RefreshMiniWindow()
end

function HJBT:OnDuelStarted(eventCode)
    self.saved.activeDuel =
    {
        startedAt = self:GetNow(),
    }
end

function HJBT:OnDuelFinished(eventCode, result, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName, opponentAlliance, opponentGender, opponentClassId, opponentRaceId)
    if DUEL_RESULT_FORFEIT ~= nil and result == DUEL_RESULT_FORFEIT then
        self.saved.activeDuel = nil
        return
    end

    local localWon = nil

    if DUEL_RESULT_WON ~= nil and result == DUEL_RESULT_WON then
        localWon = wasLocalPlayersResult == true
    end

    if localWon ~= true then
        self.saved.activeDuel = nil
        return
    end

    local startedAt = 0

    if self.saved.activeDuel ~= nil and self.saved.activeDuel.startedAt ~= nil then
        startedAt = tonumber(self.saved.activeDuel.startedAt) or 0
    end

    local durationSeconds = 0

    if startedAt > 0 then
        durationSeconds = self:GetNow() - startedAt
    end

    local minimumSeconds = tonumber(self.saved.settings.minimumDuelSeconds or 10) or 10

    if durationSeconds > 0 and durationSeconds < minimumSeconds then
        HJBTChat("Bounty claim ignored because the duel was under " .. tostring(minimumSeconds) .. " seconds.")
        self.saved.activeDuel = nil
        return
    end

    local bounty = self:FindBountyForOpponent(opponentCharacterName, opponentDisplayName)

    if bounty == nil then
        self.saved.activeDuel = nil
        return
    end

    self:SaveBountyClaim(bounty.targetAccount, bounty.amount, durationSeconds)
    self.saved.activeDuel = nil
end


function HJBT:CreateWindow()
    if self.window ~= nil then
        return
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("HeyJensenBountyTrackerWindow")
    window:SetDimensions(760, 570)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 35)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local background = wm:CreateControl("HeyJensenBountyTrackerBoardBackground", window, CT_TEXTURE)
    background:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    background:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    background:SetTexture(self.boardTexture)
    background:SetAlpha(1)

    self:CreateLabel(window, "HeyJensenBountyTrackerInstructions",
        "How it works:\n" ..
        "1. Enter a target and bounty amount.\n" ..
        "2. Click Mail Bounty Gold. Mail opens to @Hey-Jensen.\n" ..
        "3. Attach the gold manually before sending.\n" ..
        "4. The board updates when you see an official bounty post from @Hey-Jensen.",
        100, 178, 560, 90, "ZoFontGame", 1, 0.94, 0.78, 1)

    self:CreateLabel(window, "HeyJensenBountyTrackerTargetLabel", "Target ESO Account", 112, 286, 230, 22, "ZoFontGameBold", 1, 1, 1, 1)
    local targetEdit = self:CreateEditBox(window, "HeyJensenBountyTrackerTargetEdit", 112, 312, 245, 32, "@TargetName")

    self:CreateLabel(window, "HeyJensenBountyTrackerAmountLabel", "Gold Amount", 405, 286, 180, 22, "ZoFontGameBold", 1, 1, 1, 1)
    local amountEdit = self:CreateEditBox(window, "HeyJensenBountyTrackerAmountEdit", 405, 312, 155, 32, "100000")

    self:CreateButton(window, "HeyJensenBountyTrackerMailButton", "Mail Bounty Gold", 110, 360, 150, 32, function()
        self:OpenBountyMail(self:GetWindowTarget(), self:GetWindowAmount())
    end)

    self:CreateButton(window, "HeyJensenBountyTrackerAnnounceButton", "Admin Zone Post", 275, 360, 145, 32, function()
        self:OpenZoneAnnouncement(self:GetWindowTarget(), self:GetWindowAmount())
    end)

    self:CreateButton(window, "HeyJensenBountyTrackerRemoveButton", "Admin Remove", 435, 360, 125, 32, function()
        self:OpenRemoveAnnouncement(self:GetWindowTarget())
    end)

    self:CreateButton(window, "HeyJensenBountyTrackerPrintButton", "Print Board", 575, 360, 105, 32, function()
        self:PrintBounties()
    end)

    self:CreateButton(window, "HeyJensenBountyTrackerCloseButton", "Close", 610, 508, 82, 28, function()
        window:SetHidden(true)
    end)

    self:CreateLabel(window, "HeyJensenBountyTrackerBoardHeader", "Active Bounties", 112, 405, 220, 26, "ZoFontWinH3", 1, 1, 1, 1)
    local boardText = self:CreateLabel(window, "HeyJensenBountyTrackerBoardText", "", 112, 432, 520, 70, "ZoFontGame", 1, 0.94, 0.78, 1)

    self:CreateButton(window, "HeyJensenBountyTrackerClaimMailButton", "Mail Last Claim", 112, 505, 135, 28, function()
        self:OpenClaimMail()
    end)

    local claimText = self:CreateLabel(window, "HeyJensenBountyTrackerClaimText", "", 260, 508, 370, 28, "ZoFontGame", 1, 0.94, 0.78, 1)

    self.window =
    {
        window = window,
        targetEdit = targetEdit,
        amountEdit = amountEdit,
        boardText = boardText,
        claimText = claimText,
    }

    self:RefreshWindow()
end

function HJBT:RefreshWindow()
    if self.window == nil or self.window.boardText == nil then
        return
    end

    self.window.boardText:SetText(self:GetBountyBoardText())

    if self.window.claimText ~= nil then
        if self.saved.lastClaim ~= nil then
            self.window.claimText:SetText("Last claim: " .. tostring(self.saved.lastClaim.targetAccount) .. " code " .. tostring(self.saved.lastClaim.code))
        else
            self.window.claimText:SetText("No bounty claim saved yet.")
        end
    end

    if self.miniWindow ~= nil then
        self:RefreshMiniWindow()
    end
end

function HJBT:OpenWindow()
    self:CreateWindow()
    self:RefreshWindow()
    self.window.window:SetHidden(false)
end

function HJBT:ToggleWindow()
    self:CreateWindow()
    self:RefreshWindow()
    self.window.window:SetHidden(not self.window.window:IsHidden())
end

function HJBT:PrintBounties()
    HJBTChat("Active bounties")
    d(self:GetBountyBoardText())
end


function HJBT:GetTopBountiesText(limit)
    local list = self:GetSortedBounties()
    limit = limit or 3

    if #list == 0 then
        return "No active bounties yet.\nWatch for official posts from @Hey-Jensen."
    end

    local text = ""

    for index = 1, zo_min(limit, #list) do
        local bounty = list[index]
        text = text .. tostring(index) .. ". " .. bounty.targetAccount .. "  " .. self:FormatGold(bounty.amount) .. " gold"

        if index < zo_min(limit, #list) then
            text = text .. "\n"
        end
    end

    return text
end

function HJBT:CreateMiniWindow()
    if self.miniWindow ~= nil then
        return
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("HeyJensenBountyTrackerMiniWindow")
    window:SetDimensions(430, 322)
    window:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -45, 95)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local background = wm:CreateControl("HeyJensenBountyTrackerMiniBoardBackground", window, CT_TEXTURE)
    background:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    background:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    background:SetTexture(self.boardTexture)
    background:SetAlpha(1)

    self:CreateLabel(window, "HeyJensenBountyTrackerMiniHeader", "Top 3 Bounties", 72, 112, 285, 28, "ZoFontWinH3", 1, 1, 1, 1)
    local topText = self:CreateLabel(window, "HeyJensenBountyTrackerMiniTopText", "", 72, 146, 290, 78, "ZoFontGame", 1, 0.94, 0.78, 1)

    self:CreateButton(window, "HeyJensenBountyTrackerMiniOpenButton", "Open Board", 82, 234, 110, 28, function()
        self:OpenWindow()
    end)

    self:CreateButton(window, "HeyJensenBountyTrackerMiniCloseButton", "Close", 238, 234, 82, 28, function()
        window:SetHidden(true)
    end)

    self.miniWindow =
    {
        window = window,
        topText = topText,
    }

    self:RefreshMiniWindow()
end

function HJBT:RefreshMiniWindow()
    if self.miniWindow == nil or self.miniWindow.topText == nil then
        return
    end

    self.miniWindow.topText:SetText(self:GetTopBountiesText(3))
end

function HJBT:OpenMiniWindow()
    self:CreateMiniWindow()
    self:RefreshMiniWindow()
    self.miniWindow.window:SetHidden(false)
end


function HJBT:HandleSlashCommand(text)
    local input = tostring(text or "")
    local command, rest = input:match("^(%S*)%s*(.-)$")
    command = string.lower(command or "")
    rest = rest or ""

    if command == "" or command == "open" then
        self:ToggleWindow()
    elseif command == "mini" then
        self:OpenMiniWindow()
    elseif command == "mail" or command == "add" or command == "post" then
        local target, amount = rest:match("^(%S+)%s+([%d,]+)")
        self:OpenBountyMail(target, amount)
    elseif command == "announce" or command == "zone" then
        local target, amount = rest:match("^(%S+)%s+([%d,]+)")
        self:OpenZoneAnnouncement(target, amount)
    elseif command == "remove" or command == "paid" then
        local target = rest:match("^(%S+)")
        self:OpenRemoveAnnouncement(target)
    elseif command == "claim" then
        self:OpenClaimMail()
    elseif command == "verify" then
        local killer, target, amount, code, timestamp = rest:match("^(%S+)%s+(%S+)%s+([%d,]+)%s+(%d%d%d%d%d)%s+(%d+)")
        if killer == nil then
            HJBTChat("Use /hjb verify @Killer @Target 100000 12345 1234567890")
        elseif self:ValidateClaimCode(killer, target, amount, timestamp, code) then
            HJBTChat("Valid bounty claim code for " .. tostring(killer) .. " vs " .. tostring(target) .. ".")
        else
            HJBTChat("Invalid bounty claim code.")
        end
    elseif command == "list" or command == "board" then
        self:PrintBounties()
    else
        HJBTChat("Commands:")
        d("/hjb")
        d("/hjb mini")
        d("/hjb mail @TargetName 100000")
        d("/hjb announce @TargetName 100000")
        d("/hjb remove @TargetName")
        d("/hjb claim")
        d("/hjb verify @Killer @Target 100000 12345 1234567890")
        d("/hjb list")
    end
end

function HJBT:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide("HeyJensenBountyTrackerSavedVariables", 1, nil, self.defaults)

    if self.saved.settings == nil then
        self.saved.settings = {}
    end

    if self.saved.settings.adminAccount == nil then
        self.saved.settings.adminAccount = "@Hey-Jensen"
    end

    if self.saved.settings.bankAccount == nil then
        self.saved.settings.bankAccount = "@Hey-Jensen"
    end

    if self.saved.bounties == nil then
        self.saved.bounties =
        {
            active = {},
            history = {},
        }
    end

    if self.saved.bounties.active == nil then
        self.saved.bounties.active = {}
    end

    if self.saved.bounties.history == nil then
        self.saved.bounties.history = {}
    end

    if self.saved.bounties.claims == nil then
        self.saved.bounties.claims = {}
    end

    if self.saved.settings.minimumDuelSeconds == nil then
        self.saved.settings.minimumDuelSeconds = 10
    end

    EVENT_MANAGER:RegisterForEvent(self.name .. "DuelStarted", EVENT_DUEL_STARTED, function(eventCode)
        self:OnDuelStarted(eventCode)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "DuelFinished", EVENT_DUEL_FINISHED, function(eventCode, result, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName, opponentAlliance, opponentGender, opponentClassId, opponentRaceId)
        self:OnDuelFinished(eventCode, result, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName, opponentAlliance, opponentGender, opponentClassId, opponentRaceId)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "Chat", EVENT_CHAT_MESSAGE_CHANNEL, function(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
        self:OnChatMessage(channelType, fromName, text, isCustomerService, fromDisplayName)
    end)

    SLASH_COMMANDS["/hjb"] = function(text)
        self:HandleSlashCommand(text)
    end

    SLASH_COMMANDS["/bounty"] = function(text)
        self:HandleSlashCommand(text)
    end

    if zo_callLater ~= nil then
        zo_callLater(function()
            self:OpenMiniWindow()
        end, 1800)
    else
        self:OpenMiniWindow()
    end

    HJBTChat("Loaded. Type /hjb to open the bounty board.")
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= HJBT.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(HJBT.name, EVENT_ADD_ON_LOADED)
    HJBT:Initialize()
end

EVENT_MANAGER:RegisterForEvent(HJBT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
