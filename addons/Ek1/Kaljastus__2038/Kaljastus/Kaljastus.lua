Kaljastus = {
	Author = "Ek1",
	Description = "Wears the kettle and a towel when fishing and changes to old clothes if someone comes poking with a wrong stick.",
	Version = "4.0-20180621",
	License = "BY-SA = Creative Commons Attribution-ShareAlike 4.0 International License"
	}
local ADDON_NAME = "Kaljastus"
local vanhaHattu

-- EVENT_FISHING_LURE_SET (number eventCode, number fishingLure)
function Kaljastus.kattilaPaahan(_, numberfishingLure)
	vanhaHattu = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT)
	-- d( vanhaHattu )
	-- kattila on 174, kruunu 1107
	UseCollectible(174)
	UseCollectible(753)
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_FISHING_LURE_SET, Kaljastus.kattilaPaahan)

--[[
-- EVENT_FISHING_LURE_CLEARED (number eventCode)
function Kaljastus.uuttaKoloaKohti(_, numberfishingLure)
	-- d( vanhaHattu )
	UseCollectible(vanhaHattu)
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_FISHING_LURE_CLEARED, Kaljastus.uuttaKoloaKohti)


-- EVENT_PLAYER_COMBAT_STATE
function Kaljastus.sharkAttack(_, inCombat)
--	 d( inCombat )
	if inCombat and GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME) == 753 then
		UseCollectible(vanhaHattu)
		UseCollectible(753)
	end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, Kaljastus.sharkAttack)



]]--