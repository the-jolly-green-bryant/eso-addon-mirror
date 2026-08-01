LibRadialMenu = LibRadialMenu or {}



local LIBRADIAL_WHEEL = HOTBAR_CATEGORY_MAX_VALUE + 100
--ZO_CreateStringId(string.format("SI_HOTBARCATEGORY%d",LIBRADIAL_WHEEL), "Addon Entries") -- done in lang

local UTILITY_WHEEL_CATEGORIES =
{
	HOTBAR_CATEGORY_QUICKSLOT_WHEEL,
	HOTBAR_CATEGORY_ALLY_WHEEL,
	HOTBAR_CATEGORY_MEMENTO_WHEEL,
	HOTBAR_CATEGORY_TOOL_WHEEL,
	HOTBAR_CATEGORY_EMOTE_WHEEL,
	--LIBRADIAL_WHEEL, -- now it is dynamically inserted
}
local NUM_UTILITY_WHEEL_CATEGORIES = #UTILITY_WHEEL_CATEGORIES



function ZO_UtilityWheel_Shared:GetHotbarCategory()
	return UTILITY_WHEEL_CATEGORIES[self.currentHotbarCategoryIndex]
end

function ZO_UtilityWheel_Shared:GetNextHotbarCategoryIndex()
	return self.currentHotbarCategoryIndex % NUM_UTILITY_WHEEL_CATEGORIES + 1
end

function ZO_UtilityWheel_Shared:GetPreviousHotbarCategoryIndex()
	local categoryIndex = self.currentHotbarCategoryIndex - 1
	if categoryIndex == 0 then
		categoryIndex = NUM_UTILITY_WHEEL_CATEGORIES
	end
	return categoryIndex
end

function ZO_UtilityWheel_Shared:GetNextHotbarCategory()
	return UTILITY_WHEEL_CATEGORIES[self:GetNextHotbarCategoryIndex()]
end

function ZO_UtilityWheel_Shared:GetPreviousHotbarCategory()
	return UTILITY_WHEEL_CATEGORIES[self:GetPreviousHotbarCategoryIndex()]
end



LibRadialMenu.registeredEntries = { }
LibRadialMenu.addonNames = { }

local registeredEntries = LibRadialMenu.registeredEntries
local addonNames = LibRadialMenu.addonNames

function LibRadialMenu:RegisterAddon(addonId, addonName)
	if type(addonName) == "number" then addonName = GetString(addonName) end

	addonNames[addonId] = addonName
	registeredEntries[addonId] = {}
end


function LibRadialMenu:RegisterEntry(addonId, entryName, entryId, entryIcon, entryCallback, entryDescription)
	if type(entryName) == "number" then entryName = GetString(entryName) end
	if type(entryDescription) == "number" then entryDescription = GetString(entryDescription) end

	if (type(registeredEntries[addonId]) ~= "table") or (type(entryCallback) ~= "function") then
		d(string.format("LibRadialMenu: Failed to register entry %s for addon %s", entryName, addonId))
		return
	end
	registeredEntries[addonId][entryId] = {
		name = entryName,
		icon = entryIcon,
		callback = entryCallback,
		description = entryDescription,
	}
end


LibRadialMenu.libRadialWheelEntries = { }


ZO_PreHook(ZO_UtilityWheel_Shared, "PopulateMenu", function(self)
	local hotbarCategory = self:GetHotbarCategory()
	--d("Populating "..GetString("SI_HOTBARCATEGORY",hotbarCategory))

	if hotbarCategory == LIBRADIAL_WHEEL then

		for i, entryData in ipairs(LibRadialMenu.libRadialWheelEntries) do
			local entryAddon = registeredEntries[entryData.addon]
			if entryAddon and entryAddon[entryData.entry] and addonNames[entryData.addon] then
				local entry = entryAddon[entryData.entry]
				local addonName = addonNames[entryData.addon]
				local slotIcon = entry.icon or ""
				local slotname = string.format("%s\n%s", entry.name or entryData.entry, ZO_NORMAL_TEXT:Colorize(addonName))
				local callback = entry.callback
				self.menu:AddEntry(slotname, slotIcon, slotIcon, callback, {slotNum = i, name = slotname})
			else
				self.menu:AddEntry(ZO_UTILITY_SLOT_EMPTY_STRING, ZO_UTILITY_SLOT_EMPTY_TEXTURE, ZO_UTILITY_SLOT_EMPTY_TEXTURE, nil, { slotNum = i })
			end
		end

		self.previousCategoryControl:SetHidden(false)
		self.nextCategoryControl:SetHidden(false)

		self:RefreshCategories()
		return true
	end
	return false
end)






LibRadialMenu:RegisterAddon("libradialmenu", "LibRadialMenu")



LibRadialMenu:RegisterEntry("libradialmenu", GetString(SI_ADDON_MANAGER_RELOAD), "reloadui", "/esoui/art/login/gamepad/loading-ouroboros.dds",
	function() ReloadUI() end,
	GetString(SI_GAMEPAD_ADDON_MANAGER_DELETE_SAVED_VARIABLES_RELOAD_UI_WARNING))





LibRadialMenu.name = "LibRadialMenu"


function LibRadialMenu.OnAddOnLoaded(event, addonName)

	if addonName ~= LibRadialMenu.name then return end

	LibRadialMenu:Initialize()
end
 

local defaultSettings = {
	numSlots = 12,
	slots = {},
	cntype = "simplecn",
	wheelIndex = 6
}


function LibRadialMenu.insertWheelAtIndex(index)
	if index == 0 then return end
	table.insert(UTILITY_WHEEL_CATEGORIES, index, LIBRADIAL_WHEEL)
	NUM_UTILITY_WHEEL_CATEGORIES = #UTILITY_WHEEL_CATEGORIES
end

local vanillaWheel = {
	HOTBAR_CATEGORY_QUICKSLOT_WHEEL,
	HOTBAR_CATEGORY_ALLY_WHEEL,
	HOTBAR_CATEGORY_MEMENTO_WHEEL,
	HOTBAR_CATEGORY_TOOL_WHEEL,
	HOTBAR_CATEGORY_EMOTE_WHEEL,
}
function LibRadialMenu.resetTable()
	for i,v in pairs(UTILITY_WHEEL_CATEGORIES) do
		UTILITY_WHEEL_CATEGORIES[i] = nil
	end
	for i,v in ipairs(vanillaWheel) do
		UTILITY_WHEEL_CATEGORIES[i] = v
	end
	NUM_UTILITY_WHEEL_CATEGORIES = #UTILITY_WHEEL_CATEGORIES
end


-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function LibRadialMenu:Initialize()

	LibRadialMenu.vars = ZO_SavedVars:NewAccountWide("RadialMenuSlots", 1, nil, defaultSettings)

	

	if ZO_IsTableEmpty(LibRadialMenu.vars.slots) then -- insert default if first install
		LibRadialMenu.vars.slots[LibRadialMenu.vars.numSlots] = {addon="libradialmenu",entry="opensettings"}
		LibRadialMenu.vars.wheelIndex = 0 -- only set to 0 if the user hasnt already set stuff up
	end

	LibRadialMenu.insertWheelAtIndex(LibRadialMenu.vars.wheelIndex or 0)

	LibRadialMenu.libRadialWheelEntries = LibRadialMenu.vars.slots
	LibRadialMenu.UpdateSettingsMenu()

	EVENT_MANAGER:UnregisterForEvent(LibRadialMenu.name, EVENT_ADD_ON_LOADED)
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(LibRadialMenu.name, EVENT_ADD_ON_LOADED, LibRadialMenu.OnAddOnLoaded)