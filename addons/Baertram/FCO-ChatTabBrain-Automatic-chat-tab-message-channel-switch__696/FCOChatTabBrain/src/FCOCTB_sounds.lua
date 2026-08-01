FCOCTB = FCOCTB or {}
local FCOCTB = FCOCTB

--Update the available sounds of the game
FCOCTB.sounds = {}
if SOUNDS then
	for soundName, _ in pairs(SOUNDS) do
		if soundName ~= "NONE" then
			table.insert(FCOCTB.sounds, soundName)
        end
    end
	if #FCOCTB.sounds > 0 then
        table.sort(FCOCTB.sounds)
    	table.insert(FCOCTB.sounds, 1, "NONE")
	end
end
if #FCOCTB.sounds <= 1 then
	d("[FCOChatTabBrain} No sounds could be found! Addon won't work properly!")
end

