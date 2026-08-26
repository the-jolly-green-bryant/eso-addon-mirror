-- Integrated into ESO Adventurer Suite; original data/marker architecture retained and namespaced.

local Settings = {}
zo_mixin(Settings, ZO_CallbackObject)
EASLoreLibrary:RegisterModule("settings", Settings)

--[[
All persisted addon settings, backed by account-wide saved variables:
- IsPinTypeEnabled/SetPinTypeEnabled: whether each pin type
  (EASLoreLibrary.LOREBOOK / EASLoreLibrary.EIDETICBOOK) is shown. Fires
  "FilterChanged" (pinTypeId, enabled).
- Get/Set: everything else, e.g. the on/off + range for the 3D world and
  compass pin systems ("worldPinsEnabled", "worldPinsDistance", etc). Fires
  "SettingChanged" (key, value).
Pin modules listen for whichever of these applies, so they can react
immediately instead of waiting for their next periodic tick.
]]--

local DEFAULTS = {
	loreBooksEnabled = true,
	enabled = {
		[EASLoreLibrary.LOREBOOK] = true,
		[EASLoreLibrary.EIDETICBOOK] = false,
		[EASLoreLibrary.MARKER] = true,
	},
	worldPinsEnabled = true,
	hideQuestDependentWorldPins = true,
	worldPinsDistance = 250,
	compassPinsEnabled = true,
	compassPinsDistance = 300,
}

function Settings:Initialize()
	self.savedVars = ZO_SavedVars:NewAccountWide("EASLoreLibrarySavedVariables", 1, "Settings", DEFAULTS)
end

function Settings:IsEnabled()
	return self.savedVars.loreBooksEnabled ~= false
end

function Settings:IsPinTypeEnabled(pinTypeId)
	if not self:IsEnabled() then return false end
	return self.savedVars.enabled[pinTypeId] ~= false
end

function Settings:SetPinTypeEnabled(pinTypeId, enabled)
	enabled = enabled and true or false
	if self.savedVars.enabled[pinTypeId] == enabled then return end
	self.savedVars.enabled[pinTypeId] = enabled
	self:FireCallbacks("FilterChanged", pinTypeId, enabled)
end

function Settings:Get(key)
	return self.savedVars[key]
end

function Settings:Set(key, value)
	if self.savedVars[key] == value then return end
	self.savedVars[key] = value
	self:FireCallbacks("SettingChanged", key, value)
	if key == "loreBooksEnabled" then
		-- Force map/filter/tracked-marker modules to immediately clear or restore pins.
		self:FireCallbacks("FilterChanged", nil, value)
	end
end
