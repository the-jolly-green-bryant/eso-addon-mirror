--Update the available sounds from the game
FCOUS = FCOUS or {}
local FCOUS = FCOUS
FCOUS.sounds = {}
if SOUNDS then
    for soundName, _ in pairs(SOUNDS) do
        if soundName ~= "NONE" then
            table.insert(FCOUS.sounds, soundName)
        end
    end
    if #FCOUS.sounds > 0 then
        table.sort(FCOUS.sounds)
        table.insert(FCOUS.sounds, 1, "NONE")
    end
end
if #FCOUS.sounds <= 0 then
    d("[FCOUS] No sounds could be found! Addon won't work properly!")
end