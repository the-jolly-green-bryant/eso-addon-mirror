-- ESO Adventurer Suite
-- v0.29.661 - bank presentation cleanup.
-- Keep the Suite bank grid/categories/interactions, but remove the full dark
-- panel backdrop and the Suite WITHDRAW/DEPOSIT title requested by the user.

local EPC = ESOProgressionCoach
if not EPC then return end

local U = EPC.BankGridUnifiedV2
if not U then return end

local function cleanup(self)
    if not self then return end

    if self.bg then
        if type(self.bg.SetHidden) == "function" then self.bg:SetHidden(true) end
        if type(self.bg.SetMouseEnabled) == "function" then self.bg:SetMouseEnabled(false) end
    end

    if self.title then
        if type(self.title.SetText) == "function" then self.title:SetText("") end
        if type(self.title.SetHidden) == "function" then self.title:SetHidden(true) end
        if type(self.title.SetMouseEnabled) == "function" then self.title:SetMouseEnabled(false) end
    end
end

if type(U.CreateFor) == "function" and not U._easPresentationCleanupCreate029661 then
    U._easPresentationCleanupCreate029661 = true
    local baseCreateFor = U.CreateFor
    function U:CreateFor(...)
        local result = baseCreateFor(self, ...)
        cleanup(self)
        return result
    end
end

if type(U.Render) == "function" and not U._easPresentationCleanupRender029661 then
    U._easPresentationCleanupRender029661 = true
    local baseRender = U.Render
    function U:Render(...)
        local result = baseRender(self, ...)
        cleanup(self)
        return result
    end
end

cleanup(U)
EPC.bankPresentationCleanupFix029661 = true
