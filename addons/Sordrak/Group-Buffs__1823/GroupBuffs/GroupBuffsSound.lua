-- GroupBuffs - Sound
-- By @s0rdrak, @Graham82 (PC / EU)

--local LAM = LibStub("LibAddonMenu-2.0")

local GroupBuffs = _G['GroupBuffs']
local GroupBuffsSound = GroupBuffs.sound


 function GroupBuffsSound.Initialize()
	local soundKeys = {}
	local soundNames = {}
	local index = 1
	for key, value in pairs(SOUNDS) do 
		soundKeys[index] = key
		soundNames[index] = value
		index = index + 1
	end
	GroupBuffsSound.soundKeys = soundKeys
	GroupBuffsSound.soundNames = soundNames
 end
 
 function GroupBuffsSound.PlaySound(key)
	local soundName = SOUNDS[key]
	if soundName ~= nil then
		PlaySound(soundName)
	end
 end