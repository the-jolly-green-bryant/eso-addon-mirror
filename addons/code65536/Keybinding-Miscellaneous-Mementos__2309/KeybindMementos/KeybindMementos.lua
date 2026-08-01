KeybindMementos = {
	name = "KeybindMementos",

	mementos = {
		[ 601] = "MUDBALL",
		[1108] = "BLOSSOMS",
		[5889] = "RAINBOW",
		[6932] = "SNOWBALL",
		[7862] = "TOTEM",
		[8883] = "SENTINEL_RELIC",
	}
}

if (not SI_KEYBINDINGS_CATEGORY_MEMENTOS) then
	local GetStringPlural = function(...) return zo_strformat("<<m:1>>", GetString(...), 2) end
	ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_MEMENTOS", string.format("%s/%s", GetStringPlural("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_MEMENTO), GetStringPlural("SI_SPECIALIZEDCOLLECTIBLETYPE", SPECIALIZED_COLLECTIBLE_TYPE_TOOL)))
end

local function OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= KeybindMementos.name) then return end

	EVENT_MANAGER:UnregisterForEvent(KeybindMementos.name, EVENT_ADD_ON_LOADED)

	for id, code in pairs(KeybindMementos.mementos) do
		local name, _, _, _, unlocked = GetCollectibleInfo(id)
		if (unlocked) then
			ZO_CreateStringId("SI_BINDING_NAME_" .. code, zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, name))
		end
	end
end

EVENT_MANAGER:RegisterForEvent(KeybindMementos.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
