local RB = RanckorsBaggage
local ICONS = RB.ICONS
local COLORS = RB.COLORS
local CURRENCY_NAMES = RB.CURRENCY_NAMES

function RB:GetCurrencySafely(currencyType, location)
    local name = CURRENCY_NAMES[currencyType] or ("Unknown(" .. tostring(currencyType) .. ")")

    if not CURRENCY_NAMES[currencyType] and not self.hasShownCurrencyWarning then
        d(self.name .. " - Warning: Invalid currency type " .. name)
        self.hasShownCurrencyWarning = true
        return nil
    end

    local amt = GetCurrencyAmount(currencyType, location)
    if amt == 0 and not self.hasShownCurrencyWarning then
        d(self.name .. " - Warning: " .. name .. " returned 0. Verify if this is correct.")
        self.hasShownCurrencyWarning = true
    end

    return amt
end

function RB:UpdateCurrencyData()
    -- Player-held
    self.gold              = self:GetCurrencySafely(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    self.alliancePoints    = self:GetCurrencySafely(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER)
    self.telVar            = self:GetCurrencySafely(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)
    -- self.eventTickets    = self:GetCurrencySafely(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)
    self.tomePointCaches   = self:GetCurrencySafely(CURT_TOME_POINT_CACHES, CURRENCY_LOCATION_ACCOUNT)
    self.tomePoints        = self:GetCurrencySafely(CURT_TOME_POINTS, CURRENCY_LOCATION_ACCOUNT)
    self.tradeBars         = self:GetCurrencySafely(CURT_TRADE_BARS, CURRENCY_LOCATION_ACCOUNT)
    self.tomeTokens        = self:GetCurrencySafely(CURT_TOME_TOKENS, CURRENCY_LOCATION_ACCOUNT)
    self.undauntedKeys     = self:GetCurrencySafely(CURT_UNDAUNTED_KEYS, CURRENCY_LOCATION_ACCOUNT)
    self.transmuteCrystals = self:GetCurrencySafely(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
    self.crownGems         = self:GetCurrencySafely(CURT_CROWN_GEMS, CURRENCY_LOCATION_ACCOUNT)
    self.imperialFragments = self:GetCurrencySafely(CURT_IMPERIAL_FRAGMENTS, CURRENCY_LOCATION_ACCOUNT)
    self.sealsOfEndeavour  = self:GetCurrencySafely(CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT)
    self.writVouchers      = self:GetCurrencySafely(CURT_WRIT_VOUCHERS, CURRENCY_LOCATION_CHARACTER)
    self.archivalFortunes  = self:GetCurrencySafely(CURT_ARCHIVAL_FORTUNES, CURRENCY_LOCATION_ACCOUNT)
    self.crowns            = self:GetCurrencySafely(CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT)

    -- Bags
    self.currentBagSpace = GetNumBagUsedSlots(BAG_BACKPACK)
    self.maxBagSpace     = GetBagSize(BAG_BACKPACK)

    -- Banked currencies
    self.bankedGold           = self:GetCurrencySafely(CURT_MONEY, CURRENCY_LOCATION_BANK)
    self.bankedAlliancePoints = self:GetCurrencySafely(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_BANK)
    self.bankedTelVar         = self:GetCurrencySafely(CURT_TELVAR_STONES, CURRENCY_LOCATION_BANK)
    self.bankedWritVouchers   = self:GetCurrencySafely(CURT_WRIT_VOUCHERS, CURRENCY_LOCATION_BANK)

    -- Bank space
    local bankUsed    = GetNumBagUsedSlots(BAG_BANK)
    local bankMax     = GetBagSize(BAG_BANK)
    local subBankUsed = GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK)
    local subBankMax  = GetBagSize(BAG_SUBSCRIBER_BANK)

    if IsESOPlusSubscriber() then
        self.combinedBankUsedSpace = bankUsed + subBankUsed
        self.combinedMaxBankSpace  = bankMax + subBankMax
        self.maxTransmuteCrystals  = 3000
    else
        self.combinedBankUsedSpace = bankUsed + subBankUsed
        self.combinedMaxBankSpace  = bankMax
        self.maxTransmuteCrystals  = 1500
    end
end

function RB:BuildInfoText()
    local s = {}
    local show = self.saved.displaySettings or {}

    local function addLine(color, icon, text)
        s[#s + 1] = string.format("%s|t24:24:%s|t %s|r\n", color, icon, text)
    end

    s[#s + 1] = string.format("%s--------Player--------|r\n", COLORS.SECTION)

    if show[CURT_MONEY] ~= false then
        addLine(COLORS.GOLD, ICONS.GOLD, self:ZOComma(self.gold))
    end
    if show[CURT_ALLIANCE_POINTS] ~= false then
        addLine(COLORS.AP, ICONS.AP, self:ZOComma(self.alliancePoints))
    end
    if show[CURT_TELVAR_STONES] ~= false then
        addLine(COLORS.TELVAR, ICONS.TELVAR, self:ZOComma(self.telVar))
    end
    if show[CURT_TOME_POINT_CACHES] ~= false then
        addLine(COLORS.GOLD, ICONS.TOME_POINT_CACHES, self:ZOComma(self.tomePointCaches))
    end
    if show[CURT_TOME_POINTS] ~= false then
        addLine(COLORS.GOLD, ICONS.TOME_POINTS, self:ZOComma(self.tomePoints))
    end
    if show[CURT_TRADE_BARS] ~= false then
        addLine(COLORS.GOLD, ICONS.TRADE_BARS, self:ZOComma(self.tradeBars))
    end
    if show[CURT_TOME_TOKENS] ~= false then
        addLine(COLORS.GOLD, ICONS.TOME_TOKENS, self:ZOComma(self.tomeTokens))
    end
    if show[CURT_UNDAUNTED_KEYS] ~= false then
        addLine(COLORS.UNDAUNTED, ICONS.UNDAUNTED_KEY, self:ZOComma(self.undauntedKeys))
    end
    if show[CURT_CHAOTIC_CREATIA] ~= false then
        addLine(COLORS.TRANSMUTE, ICONS.TRANSMUTE,
            string.format("%s/%s", self:ZOComma(self.transmuteCrystals), self:ZOComma(self.maxTransmuteCrystals)))
    end
    if show[CURT_CROWN_GEMS] ~= false then
        addLine(COLORS.CROWN_GEMS, ICONS.CROWN_GEMS, self:ZOComma(self.crownGems))
    end
    if show[CURT_IMPERIAL_FRAGMENTS] ~= false then
        addLine(COLORS.IMPERIAL, ICONS.IMPERIAL_FRAGMENT, self:ZOComma(self.imperialFragments))
    end
    if show[CURT_ENDEAVOR_SEALS] ~= false then
        addLine(COLORS.SEALS, ICONS.SEALS, self:ZOComma(self.sealsOfEndeavour))
    end
    if show[CURT_WRIT_VOUCHERS] ~= false then
        addLine(COLORS.WRIT, ICONS.WRIT_VOUCHER, self:ZOComma(self.writVouchers))
    end
    if show[CURT_ARCHIVAL_FORTUNES] ~= false then
        addLine(COLORS.ARCHIVAL, ICONS.ARCHIVAL, self:ZOComma(self.archivalFortunes))
    end
    if show[CURT_CROWNS] ~= false then
        addLine(COLORS.CROWNS, ICONS.CROWNS, self:ZOComma(self.crowns))
    end

    if show.BagSpace ~= false then
        local pct = (self.currentBagSpace / math.max(1, self.maxBagSpace)) * 100
        addLine(self:UsageColor(pct), ICONS.BAG, string.format("%d/%d", self.currentBagSpace, self.maxBagSpace))
    end

    s[#s + 1] = string.format("%s--------Banked--------|r\n", COLORS.SECTION)

    if show.BankedGold ~= false then
        addLine(COLORS.GOLD, ICONS.GOLD, self:ZOComma(self.bankedGold))
    end
    if show.BankedAlliancePoints ~= false then
        addLine(COLORS.AP, ICONS.AP, self:ZOComma(self.bankedAlliancePoints))
    end
    if show.BankedTelVar ~= false then
        addLine(COLORS.TELVAR, ICONS.TELVAR, self:ZOComma(self.bankedTelVar))
    end
    if show.BankedWritVouchers ~= false then
        addLine(COLORS.WRIT, ICONS.WRIT_VOUCHER, self:ZOComma(self.bankedWritVouchers))
    end
    if show.BankSpace ~= false then
        local pct = (self.combinedBankUsedSpace / math.max(1, self.combinedMaxBankSpace)) * 100
        addLine(self:UsageColor(pct), ICONS.BANK, string.format("%d/%d", self.combinedBankUsedSpace, self.combinedMaxBankSpace))
    end

    return table.concat(s)
end

function RB:RequestUpdate()
    if self._pendingUpdate then return end

    self._pendingUpdate = true
    zo_callLater(function()
        self._pendingUpdate = false
        self:UpdateCurrencyData()

        if self.ui and self.ui.label then
            self.ui.label:SetText(self:BuildInfoText())
        end
    end, 50)
end