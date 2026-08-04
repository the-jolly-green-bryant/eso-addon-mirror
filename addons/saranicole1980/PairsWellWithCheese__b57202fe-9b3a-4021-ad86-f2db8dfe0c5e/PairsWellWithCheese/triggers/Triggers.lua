local IFTTT = PairsWellWithCheese

local Triggers = IFTTT.Triggers or ZO_DeferredInitializingObject:Subclass()
Triggers.items = {
  Skills = {},
  TriggerCollectibles = {},
  TriggerMounts = {},
  Swimming = {},
  Pvp = {},
}

function Triggers:Initialize(parent)
  self.parent = parent
end

function Triggers.Init( ... )
	Triggers = Triggers:New( ... )
end

IFTTT.Triggers = Triggers
