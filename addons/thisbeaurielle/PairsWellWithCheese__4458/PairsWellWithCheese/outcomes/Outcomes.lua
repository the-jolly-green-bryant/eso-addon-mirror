local IFTTT = PairsWellWithCheese

local Outcomes = IFTTT.Outcomes or ZO_DeferredInitializingObject:Subclass()
Outcomes.items = {
  Collectible = {},
}

function Outcomes:Initialize(parent)
  self.parent = parent
end

function Outcomes.Init( ... )
	Outcomes = Outcomes:New( ... )
end

IFTTT.Outcomes = Outcomes
