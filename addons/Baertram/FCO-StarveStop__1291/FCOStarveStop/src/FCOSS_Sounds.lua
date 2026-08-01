if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop
------------------------------------------------------------------------------------------------------------
-- Sounds for notifications
------------------------------------------------------------------------------------------------------------
--Update the available sounds from the game
FCOSS.sounds = {}
if SOUNDS then
	for soundName, _ in pairs(SOUNDS) do
		if soundName ~= "NONE" then
			table.insert(FCOSS.sounds, soundName)
        end
    end
	if #FCOSS.sounds > 0 then
        table.sort(FCOSS.sounds)
    	table.insert(FCOSS.sounds, 1, "NONE")
	end
end
if #FCOSS.sounds <= 0 then
	d("[FCOStarveStop} No sounds could be found! Addon won't work properly!")
end

