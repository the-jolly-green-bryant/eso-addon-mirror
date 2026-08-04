local IFTTT = PairsWellWithCheese

local Links = IFTTT.Links or ZO_DeferredInitializingObject:Subclass()

function Links:Initialize(parent)
  self.parent = parent
  self.savedVarsChar = parent.CV 
  self.savedVarsAcc = parent.AV 
end

function Links.Init( ... )
	Links = Links:New( ... )
end

IFTTT.Links = Links