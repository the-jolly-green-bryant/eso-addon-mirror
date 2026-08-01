local UMB = UnstuffMyBags or {}
local savedVars = UMB.savedVars

function UMB.GetStolenActive()
	return savedVars.stolenItems
end
function UMB.SetStolenActive(value)
	savedVars.stolenItems = value
end

function UMB.GetKeepVanityClothing()
	return savedVars.keepVanityClothing
end
function UMB.SetKeepVanityClothing(value)
	savedVars.keepVanityClothing = value
end