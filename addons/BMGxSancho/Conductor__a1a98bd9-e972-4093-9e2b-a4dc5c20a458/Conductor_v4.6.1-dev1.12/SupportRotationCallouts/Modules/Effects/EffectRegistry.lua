local SRC = SupportRotationCallouts
SRC.EffectRegistry = SRC.EffectRegistry or {}
local Registry = SRC.EffectRegistry

function Registry:Initialize()
    self.entries = self.entries or {}
    self.order = self.order or {}
end

function Registry:Register(definition)
    if not definition or not definition.key then return false end
    self:Initialize()
    local key = SRC.EffectUtilities:NormalizeKey(definition.key)
    if not key then return false end

    local existing = self.entries[key]
    definition.key = key
    self.entries[key] = definition
    if not existing then self.order[#self.order + 1] = key end
    return true
end

function Registry:Get(key)
    self:Initialize()
    return self.entries[SRC.EffectUtilities:NormalizeKey(key)]
end

function Registry:IsEnabled(key)
    local definition = self:Get(key)
    if not definition then return false end
    if definition.isEnabled then return definition.isEnabled() == true end
    return true
end

function Registry:Each(callback)
    self:Initialize()
    for _, key in ipairs(self.order) do
        local definition = self.entries[key]
        if definition then callback(definition) end
    end
end
