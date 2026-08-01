LightPlease = {
	mementos = {
		[341] = "ALMALEXIA",
		[336] = "FINVIR",
	}
}

local function OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= "LightPlease") then return end

	EVENT_MANAGER:UnregisterForEvent("LightPlease", EVENT_ADD_ON_LOADED)

	for id, code in pairs(LightPlease.mementos) do
		local name, _, _, _, unlocked = GetCollectibleInfo(id)
		if (unlocked) then
			ZO_CreateStringId("SI_BINDING_NAME_" .. code, zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, name))
		end
	end
end

EVENT_MANAGER:RegisterForEvent("LightPlease", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
