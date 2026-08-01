RiP_OKA = {
	name = "RiP_OKA",

	assistant = {
		[267] = "BANK",
		[6376] = "C_BANK",
		[301] = "MARCHAND",
		[6378] = "C_MARCHAND",
		[300] = "BLACK",
		[396] = "EXPORT",
		[397] = "MERCENARY",
	},
}

local function OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= RiP_OKA.name) then return end

	EVENT_MANAGER:UnregisterForEvent(RiP_OKA.name, EVENT_ADD_ON_LOADED)

	for id, code in pairs(RiP_OKA.assistant) do
		local name, _, _, _, unlocked = GetCollectibleInfo(id)
		if (unlocked) then
			ZO_CreateStringId("SI_BINDING_NAME_" .. code, zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, name))
		end
	end
end

EVENT_MANAGER:RegisterForEvent(RiP_OKA.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
