local lastZoneId = false
local myHeadings = {
	["de"] = "!!! ACHTUNG !!!",
	["en"] = "!!! WARNING !!!",
	["fr"] = "!!! ATTENTION  !!!",
}

local myHeadline = myHeadings[GetCVar("language.2")] or myHeadings["en"]


local function checkForPaleOrderRing()
	local currentZone = GetUnitWorldPosition("player")
	if currentZone == lastZoneId then return end
	lastZoneId = currentZone
	if GetGroupSize() < 2 or GetCurrentZoneDungeonDifficulty() < 1 then return end
	
	local theRing = false
	local itemLink1 = GetItemLink(BAG_WORN, EQUIP_SLOT_RING1, LINK_STYLE_DEFAULT)
	local itemLink2 = GetItemLink(BAG_WORN, EQUIP_SLOT_RING2, LINK_STYLE_DEFAULT)
	if GetItemLinkItemId(itemLink1) == 171436 then
		theRing = itemLink1
	elseif GetItemLinkItemId(itemLink2) == 171436 then
		theRing = itemLink2
	end
	if theRing then 
		local theText = zo_strformat("|c9e0911<<C:1>>|r", GetItemLinkName(theRing))
		if GetUnitDisplayName("player") == "@Uhryel" then 
			theText = "|c9e0911Falko, nimm den ollen Ring ab!|r"
		end	
		CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.COLLECTIBLE_UNLOCKED, string.format("|c9e0911%s|r", myHeadline), theText , "/esoui/art/icons/antiquities_ornate_ring_4.dds", nil, nil, nil, 5000)
	end
end
 
 
 EVENT_MANAGER:RegisterForEvent("UPRR_OnActivate", EVENT_PLAYER_ACTIVATED, function() zo_callLater(checkForPaleOrderRing, 4200) end)