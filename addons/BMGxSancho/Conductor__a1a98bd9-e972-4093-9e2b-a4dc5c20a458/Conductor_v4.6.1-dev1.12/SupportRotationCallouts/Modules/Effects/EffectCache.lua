local SRC = SupportRotationCallouts
SRC.EffectCache = SRC.EffectCache or {}
local Cache = SRC.EffectCache

function Cache:Initialize()
    self.effects = self.effects or {}
end

function Cache:Set(key, unitId, data)
    self:Initialize()
    key = SRC.EffectUtilities:NormalizeKey(key)
    unitId = SRC.EffectUtilities:NormalizeUnitId(unitId)
    if not key then return nil end
    self.effects[key] = self.effects[key] or {}
    self.effects[key][unitId] = data
    return data
end

function Cache:Get(key, unitId)
    self:Initialize()
    key = SRC.EffectUtilities:NormalizeKey(key)
    unitId = SRC.EffectUtilities:NormalizeUnitId(unitId)
    return key and self.effects[key] and self.effects[key][unitId] or nil
end

function Cache:Remove(key, unitId)
    self:Initialize()
    key = SRC.EffectUtilities:NormalizeKey(key)
    unitId = SRC.EffectUtilities:NormalizeUnitId(unitId)
    if not key or not self.effects[key] then return nil end
    local previous = self.effects[key][unitId]
    self.effects[key][unitId] = nil
    return previous
end

function Cache:Clear(key)
    self:Initialize()
    key = SRC.EffectUtilities:NormalizeKey(key)
    if key then self.effects[key] = nil end
end

function Cache:Each(callback)
    self:Initialize()
    for key, byUnit in pairs(self.effects) do
        for unitId, data in pairs(byUnit) do callback(key, unitId, data) end
    end
end

function Cache:HasEntries()
    self:Initialize()
    for _, byUnit in pairs(self.effects) do
        if next(byUnit) ~= nil then return true end
    end
    return false
end
