local SRC = SupportRotationCallouts
SRC.SupportEffectManager = SRC.SupportEffectManager or {}
local Manager = SRC.SupportEffectManager

function Manager:Initialize()
    if self.initialized then return end
    self.initialized = true
    SRC.EffectRegistry:Initialize()
    SRC.EffectCache:Initialize()
    SRC.EffectEvents:Initialize()
    self.updateName = SRC.name .. "SupportEffectManagerUpdate"
    EVENT_MANAGER:RegisterForUpdate(self.updateName, 200, function() self:OnUpdate() end)
end

function Manager:Register(definition)
    return SRC.EffectRegistry:Register(definition)
end

function Manager:RegisterListener(key, listener)
    SRC.EffectEvents:Register(key, listener)
end

function Manager:Publish(key, payload)
    SRC.EffectEvents:Publish(key, payload)
end

function Manager:TrackEffect(key, unitId, data)
    if not key then return nil end
    data = data or {}
    data.key = SRC.EffectUtilities:NormalizeKey(data.key or key)
    data.unitId = unitId
    return SRC.EffectCache:Set(key, unitId, data)
end

function Manager:GetEffect(key, unitId)
    return SRC.EffectCache:Get(key, unitId)
end

function Manager:RemoveEffect(key, unitId, reason)
    local previous = SRC.EffectCache:Remove(key, unitId)
    if previous then
        self:Publish(key, { kind = reason or "removed", key = key, unitId = unitId, data = previous, now = SRC.EffectUtilities:Now() })
    end
    return previous
end

function Manager:ClearEffect(key, reason)
    local normalized = SRC.EffectUtilities:NormalizeKey(key)
    SRC.EffectCache:Clear(normalized)
    self:Publish(normalized, { kind = reason or "cleared", key = normalized, now = SRC.EffectUtilities:Now() })
end

function Manager:RefreshRegisteredModules()
    SRC.EffectRegistry:Each(function(definition)
        local enabled = SRC.EffectRegistry:IsEnabled(definition.key)
        if not enabled then
            SRC.EffectCache:Clear(definition.key)
            if definition.onDisabled then definition.onDisabled() end
        elseif definition.refresh then
            definition.refresh()
        end
    end)
end

function Manager:OnUpdate()
    local now = SRC.EffectUtilities:Now()
    local expired = {}
    SRC.EffectCache:Each(function(key, unitId, data)
        if SRC.EffectUtilities:IsExpired(data, now) then
            expired[#expired + 1] = { key = key, unitId = unitId, data = data }
        elseif data.onTick then
            data.onTick(data, now)
        end
    end)
    for _, item in ipairs(expired) do
        SRC.EffectCache:Remove(item.key, item.unitId)
        self:Publish(item.key, { kind = "expired", key = item.key, unitId = item.unitId, data = item.data, now = now })
    end
end
