local class = ZO_InitializingObject:Subclass()
rewardsTrackerModulesCyrodiilAPTracker = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sModulesCyrodiilAPTracker", self.owner.name)

    --zo_callLater(function()
    --    CHAT_ROUTER:AddSystemMessage("SampleAddon test")
    --end, 30000)
end
