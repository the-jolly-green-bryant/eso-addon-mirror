AutoBank_Events = {}

function AutoBank_Events:Initialize(core)
    self.core = core

    EVENT_MANAGER:RegisterForEvent(core.name, EVENT_OPEN_BANK, function()
        self:OnBankOpen()
    end)
end

function AutoBank_Events:OnBankOpen()
    if not self.core.savedVars.enabled then return end
    if IsUnitInCombat("player") then return end

    -- EVENT_OPEN_BANK fires for housing storage containers as well as the real bank.
    -- GetBankingBag() returns BAG_BANK only when the character bank is open;
    -- storage coffers return BAG_HOUSE_BANK_ONE through BAG_HOUSE_BANK_EIGHT.
    if GetBankingBag and GetBankingBag() ~= BAG_BANK then return end

    self.core:ProcessBackpack()
end
