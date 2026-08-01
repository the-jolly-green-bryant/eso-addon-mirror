local addonId = "LibBitSet"
local class = ZO_InitializingObject:Subclass()

function class:Initialize(name)
    self.name = name
end

function class:New()
    return LibBitSetBitSet:New()
end

EVENT_MANAGER:RegisterForEvent(addonId, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName ~= addonId then
        return
    end
    assert(not _G[addonId], string.format("'%s' has already been loaded", addonId))
    _G[addonId] = class:New(addonId)
    EVENT_MANAGER:UnregisterForEvent(addonId, EVENT_ADD_ON_LOADED)
end)
