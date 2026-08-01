LorePlay = LorePlay or {}

-- === LPUtilities.lua ===
--[[
LorePlay.EVENT_ACTIVE_EMOTE = "EVENT_ACTIVE_EMOTE"
LorePlay.EVENT_ON_SMART_EMOTE = "EVENT_ON_SMART_EMOTE"
LorePlay.EVENT_ON_IDLE_EMOTE = "EVENT_ON_IDLE_EMOTE"
LorePlay.EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE = "EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE"
LorePlay.EVENT_INDICATOR_MOVED = "EVENT_INDICATOR_MOVED"
]]
-- ---


local LPUtilities = {}

function LPUtilities.DidPlayerMove(currentPlayerX, currentPlayerY)
	local newX, newY = GetMapPlayerPosition("player")
	if newX ~= currentPlayerX or newY ~= currentPlayerY then
		return newX, newY, true
	end
	return newX, newY, false
end

-- ---
LorePlay.LPUtilities = LPUtilities
