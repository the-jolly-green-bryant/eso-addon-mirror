if not GildedUI then return end

local Addon = GildedUI

function Addon:SanitizeMonitoring()
    self:SanitizeFPS()
    self:SanitizePing()
    self:SanitizeMemory()
end

function Addon:OnUpdate()
    self:UpdateFPS()
    self:UpdatePing()
    self:UpdateMemory()
end

function Addon:RegisterUpdateLoop()
    local sv = self.state.sv
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_Update")
    EVENT_MANAGER:RegisterForUpdate(self.name .. "_Update", sv.updateRate * 1000, function()
        self:OnUpdate()
    end)
end
