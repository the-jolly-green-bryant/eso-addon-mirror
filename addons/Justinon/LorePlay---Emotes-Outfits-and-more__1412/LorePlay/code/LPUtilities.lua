LPUtilities = {}

function LPUtilities.DidPlayerMove(currentPlayerX, currentPlayerY)
	local newX, newY = GetMapPlayerPosition(LorePlay.player)
	if newX ~= currentPlayerX or newY ~= currentPlayerY then
		return newX, newY, true
	end
	return newX, newY, false
end
