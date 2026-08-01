AntiDismount = {}

AntiDismount.name = "AntiDismount"
AntiDismount.defaults = {}
AntiDismount.version = 1

local blockData =
{
	{
		name = "SKILL_1",
		settingsName = "Ability 1",
	},
	{
		name = "SKILL_2",
		settingsName = "Ability 2",
	},
	{
		name = "SKILL_3",
		settingsName = "Ability 3",
	},
	{
		name = "SKILL_4",
		settingsName = "Ability 4",
	},
	{
		name = "SKILL_5",
		settingsName = "Ability 5",
	},
	{
		name = "BLOCK",
		settingsName = "Blocking",
	},
	{
		name = "ATTACK",
		settingsName = "Attacking",
	},
	{
		name = "BASH",
		settingsName = "Bashing",
	},
	{
		name = "CROUCH",
		settingsName = "Crouching",
	},
}

local panel =  
{
     type = "panel",
     name = "Anti Dismount",
     registerForRefresh = true,
     displayName = "Anti Dismount",
     author = "@Dolgubon",
}
local function shallowCopy (source, destination)
	for k, v in pairs(source) do
		destination[k] = v
	end
end

local function generateOptionCheckbox(index)
	local checkboxInfo = blockData[index]
	return {
		type = "checkbox",
		name = "Disable "..checkboxInfo.settingsName,
		tooltip = checkboxInfo.settingsName.." will be disabled when you are mounted",
		getFunc = function() return AntiDismount.settings[index] end,
		setFunc = function(value) 
			AntiDismount.settings[index] = value
			RemoveActionLayerByName("STAY_ON_THE_DAMN_MOUNT_"..checkboxInfo.name)
		end,
	}
end

local options =
{
}
for i = 1, #blockData do
	options[#options+1] = generateOptionCheckbox(i)
end
local function blockSkills(event, mounted)
	for i = 1, #blockData do
		if AntiDismount.settings[i] then
			if mounted then
				PushActionLayerByName("STAY_ON_THE_DAMN_MOUNT_"..blockData[i].name)
			else
				RemoveActionLayerByName("STAY_ON_THE_DAMN_MOUNT_"..blockData[i].name)
			end
		end
	end
	
end

function AntiDismount.OnAddOnLoaded(event, addonName)
	if addonName == AntiDismount.name then
		EVENT_MANAGER:UnregisterForEvent(AntiDismount.name, EVENT_ADD_ON_LOADED)
		AntiDismount.settings = ZO_SavedVars:NewAccountWide("AntiDismountSavedVariables", AntiDismount.version, nil, AntiDismount.defaults)
		local LAM = LibAddonMenu2
		LAM:RegisterAddonPanel("AntiAllCapsPanel", panel)
		LAM:RegisterOptionControls("AntiAllCapsPanel", options)
		EVENT_MANAGER:RegisterForEvent("STAYONTHESTUPIDMOUNT",EVENT_MOUNTED_STATE_CHANGED ,blockSkills)
		blockSkills(nil, IsMounted())
	end
end

EVENT_MANAGER:RegisterForEvent(AntiDismount.name, EVENT_ADD_ON_LOADED, AntiDismount.OnAddOnLoaded)



--PushActionLayerByName(string layerName)
-- PushActionLayerByName("BLOCK_SKILL_USAGE")