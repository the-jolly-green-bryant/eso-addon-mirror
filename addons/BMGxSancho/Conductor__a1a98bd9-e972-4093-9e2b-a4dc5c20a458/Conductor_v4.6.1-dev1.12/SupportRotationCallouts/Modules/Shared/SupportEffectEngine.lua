-- Compatibility facade retained for existing v0.6/v0.7 modules.
-- New effects should register with SupportEffectManager and EffectRegistry.
local SRC = SupportRotationCallouts
SRC.SupportEffectEngine = SRC.SupportEffectEngine or {}
local Engine = SRC.SupportEffectEngine

function Engine:Initialize()
    SRC.SupportEffectManager:Initialize()
end

function Engine:RegisterListener(key, listener)
    SRC.SupportEffectManager:RegisterListener(key, listener)
end

function Engine:Publish(key, payload)
    SRC.SupportEffectManager:Publish(key, payload)
end

function Engine:TrackEffect(key, unitId, data)
    return SRC.SupportEffectManager:TrackEffect(key, unitId, data)
end

function Engine:RemoveEffect(key, unitId)
    return SRC.SupportEffectManager:RemoveEffect(key, unitId)
end

function Engine:GetEffect(key, unitId)
    return SRC.SupportEffectManager:GetEffect(key, unitId)
end
