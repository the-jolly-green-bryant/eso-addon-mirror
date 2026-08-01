-- HarvestMap UA compatibility/localization patch
--
-- HarvestMap already has a graceful built-in localization system:
-- Harvest.GetLocalization(tag) always falls back to English if a
-- translation is missing, and its own manifest tries to load
-- Localization/$(language).lua - which silently does nothing for "ua"
-- since HarvestMap ships no such file. Because of that graceful design,
-- this patch does NOT need any of the aggressive spoofing the TTC patch
-- needed - HarvestMap never breaks or shows error popups without it.
-- This patch only adds the missing Ukrainian text on top.
--
-- Our translation data lives in Localization/ua.lua under our OWN
-- namespace (GoA_HarvestMapUA), not under Harvest, because we can't
-- guarantee the "Harvest" table already exists by the time our own
-- manifest's files run (ESO doesn't guarantee load order between
-- unrelated addons). This file is the one that actually wires our data
-- into HarvestMap, and it works no matter which addon's files happen to
-- execute first: Harvest.GetLocalization is a public function, so we
-- wrap it directly - Lua resolves "Harvest.GetLocalization(...)" at call
-- time, not when the caller was defined.

local function InstallUALocalization()
	if Harvest == nil or type(Harvest.GetLocalization) ~= "function" then
		return false
	end

	if Harvest.UAPatch_LocalizationInstalled then
		return true
	end
	Harvest.UAPatch_LocalizationInstalled = true

	local uaData = GoA_HarvestMapUA or {}
	local uaStrings = uaData.strings or {}

	local originalGetLocalization = Harvest.GetLocalization
	Harvest.GetLocalization = function(tag)
		return uaStrings[tag] or originalGetLocalization(tag)
	end

	-- Node/container name detection: merge our Ukrainian container names
	-- (heavy sack, chest-like containers, etc) into the existing table.
	-- This is purely additive - HarvestMap already keeps the English
	-- names loaded as a permanent fallback, so this only helps, it can
	-- never break detection.
	Harvest.interactableName2PinTypeId = Harvest.interactableName2PinTypeId or {}
	for name, pinTypeConstantName in pairs(uaData.interactableNames or {}) do
		local pinTypeId = Harvest[pinTypeConstantName]
		if pinTypeId then
			Harvest.interactableName2PinTypeId[zo_strlower(name)] = pinTypeId
		end
	end

	-- HarvestMap bakes its keybind display names into the string table
	-- once, at load time, using whatever Harvest.GetLocalization returned
	-- back then (likely still English if we lost the load-order race).
	-- Re-run that same step now that our translations are wired in, so
	-- the keybind names in the Controls menu are Ukrainian too.
	local keybindStrings = {
		"SI_BINDING_NAME_HARVEST_SHOW_FILTER", "SI_BINDING_NAME_SKIP_TARGET",
		"SI_BINDING_NAME_TOGGLE_WORLDPINS", "SI_BINDING_NAME_TOGGLE_MAPPINS",
		"SI_BINDING_NAME_TOGGLE_MINIMAPPINS", "SI_BINDING_NAME_HARVEST_SHOW_PANEL",
		"HARVESTFARM_GENERATOR", "HARVESTFARM_EDITOR", "HARVESTFARM_SAVE",
	}
	for _, str in pairs(keybindStrings) do
		ZO_CreateStringId(str, Harvest.GetLocalization(str))
	end

	return true
end

if not InstallUALocalization() then
	EVENT_MANAGER:RegisterForEvent(
		"GoA_HarvestMapUAPatch_PreLoad",
		EVENT_ADD_ON_LOADED,
		function()
			if InstallUALocalization() then
				EVENT_MANAGER:UnregisterForEvent("GoA_HarvestMapUAPatch_PreLoad", EVENT_ADD_ON_LOADED)
			end
		end
	)
end

-- Safety net: some UI pieces (e.g. the LibAddonMenu settings panel labels)
-- are built once, at load time, from Harvest.GetLocalization. If
-- HarvestMap happened to build them before we could hook in, those
-- specific labels may still show in English until the next /reloadui.
-- Everything else (in-game notifications, the quick filter panel, map/
-- compass tooltips, pin type names) calls Harvest.GetLocalization fresh
-- every time it's shown, so it's always correctly translated regardless
-- of load order.
EVENT_MANAGER:RegisterForEvent(
	"GoA_HarvestMapUAPatch_PlayerActivated",
	EVENT_PLAYER_ACTIVATED,
	function()
		EVENT_MANAGER:UnregisterForEvent("GoA_HarvestMapUAPatch_PlayerActivated", EVENT_PLAYER_ACTIVATED)
		InstallUALocalization()
	end
)
