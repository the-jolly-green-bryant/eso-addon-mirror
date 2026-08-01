local RB = RanckorsBaggage

function RB:OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(self.namespace, EVENT_PLAYER_ACTIVATED)
    self:UpdateCurrencyData()

    if self.ui and self.ui.label then
        self.ui.label:SetText(self:BuildInfoText())
    end

    self:RestorePosition()
    self:RestoreSize()
end

function RB:OnActionLayerPushed(_, layerIndex)
    if layerIndex == 2 or layerIndex == 3 or layerIndex == 4 or layerIndex == 6 then
        if self:IsValidWindow() then
            RanckorsBaggageWindow:SetHidden(true)
        end
    end
end

function RB:OnActionLayerPopped(_, layerIndex)
    if layerIndex == 2 or layerIndex == 3 or layerIndex == 4 or layerIndex == 6 then
        if self:IsValidWindow() then
            RanckorsBaggageWindow:SetHidden(false)
        end
    end
end

function RB:OnCurrencyUpdate()
    self:RequestUpdate()
end

function RB:OnInventoryUpdate()
    self:RequestUpdate()
end

function RB:OnSubscriptionStatusChanged()
    self:RequestUpdate()
end

function RB:RegisterEvents()
    local NS = self.namespace

    EVENT_MANAGER:RegisterForEvent(NS, EVENT_PLAYER_ACTIVATED, function()
        self:OnPlayerActivated()
    end)

    EVENT_MANAGER:RegisterForEvent(NS, EVENT_CURRENCY_UPDATE, function(...)
        self:OnCurrencyUpdate(...)
    end)

    EVENT_MANAGER:RegisterForEvent(NS, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...)
        self:OnInventoryUpdate(...)
    end)

    EVENT_MANAGER:RegisterForEvent(NS, EVENT_ACTION_LAYER_PUSHED, function(_, layerIndex)
        self:OnActionLayerPushed(_, layerIndex)
    end)

    EVENT_MANAGER:RegisterForEvent(NS, EVENT_ACTION_LAYER_POPPED, function(_, layerIndex)
        self:OnActionLayerPopped(_, layerIndex)
    end)

    EVENT_MANAGER:RegisterForEvent(NS, EVENT_ESO_PLUS_FREE_TRIAL_STATUS_CHANGED, function(...)
        self:OnSubscriptionStatusChanged(...)
    end)
end