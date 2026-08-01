local APSI 		= AutoProcessStolenItems
local settings 	= AutoProcessStolenItems.savedVars

function APSI.matchesCrowStrings(tag)
	if nil == tag then return false end
	for index, partial in pairs(AutoProcessStolenItems.crowStrings) do
		if tag:match(partial) then return true end
	end
	return false
end