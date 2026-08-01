BearSynergies = {
	name = "BearSynergies",
    version = "1.1.4",
	svName = "BearSynergiesSV",
  svVersion = 5,

	Default = {
    isAccountWide = true,
    isBlock = true,
    isTrack = true,
	},
}

local BS = BearSynergies

-- Easy creation of PanelData for each module
function BS.GetModulePanelData(name)
	return {
		type = "panel",
		name = name and string.format("Bear Synergies - %s", name) or "Bear Synergies",
		displayname = name and string.format("Bear Synergies - %s",	name) or "Bear Synergies",
		author = "|c00BFFFBjørnTheBurr|r",
		version = BS.version,
		registerForRefresh = true,
	}
end

-- Fetch abilityId with abilityName. Only support for synergies
function BS.GetSynergyId(abilityName)
  for k, v in pairs(BS.Data) do
    if v.name == abilityName then return k end
  end
end

local function Initialise()
  BS.SavedVariables = ZO_SavedVars:NewAccountWide(BS.svName, BS.svVersion, nil, BS.Default)

  if not BS.SavedVariables.isAccountWide then
    BS.SavedVariables = ZO_SavedVars:NewCharacterIdSettings(BS.svName, BS.svVersion, nil, BS.Default)
    BS.SavedVariables.isAccountWide = false
  end

  if BS.SavedVariables.isBlock then BS.Block.Initialise() end
  if BS.SavedVariables.isTrack then BS.Track.Initialise() end

	BS.BuildMenu()
end

local function OnAddonLoaded(_, addonName)
	if addonName == BS.name then
		EVENT_MANAGER:UnregisterForEvent(BS.name, EVENT_ADD_ON_LOADED)
		Initialise()
	end
end

EVENT_MANAGER:RegisterForEvent(BS.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)