--[[
-------------------------------------------------------------------------------
-- PersonnalAssistant, by Ayantir
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

	Share — copy and redistribute the material in any medium or format
	Adapt — remix, transform, and build upon the material
	The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

	Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
	NonCommercial — You may not use the material for commercial purposes.
	ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
	No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

local ADDON_NAME = "PersonnalAssistant"

PERSONNAL_ASSISTANTS = -- make this table globally accessible for the keybinds
{
	PERSONNAL_ASSISTANT_THYSIS_ANDROMO = 267,
	PERSONNAL_ASSISTANT_NUZIMEH = 300,
	PERSONNAL_ASSISTANT_PIRHARRI = 301,
	PERSONNAL_ASSISTANT_ALLARIA_ERWEN = 396,
	PERSONNAL_ASSISTANT_CASSUS_ANDRONICUS = 397,
	PERSONNAL_ASSISTANT_EZABI = 6376,
	PERSONNAL_ASSISTANT_FEZEZ = 6378,
	PERSONNAL_ASSISTANT_BASTIAN_HALLIX = 9245,
	PERSONNAL_ASSISTANT_ELENDIS = 9353,
	PERSONNAL_ASSISTANT_BARON_JANGLEPLUME = 8994,
	PERSONNAL_ASSISTANT_PEDDLER_OF_PRIZES = 8995,
	PERSONNAL_ASSISTANT_GHRASHAROG = 9745,
	PERSONNAL_ASSISTANT_FACTOTUM_PROPERTY_STEWARD = 9743,
	PERSONNAL_ASSISTANT_FACTOTUM_COMMERCE_DELEGATE = 9744,
}

local function CreateBindings()
	for _, collectibleId in pairs(PERSONNAL_ASSISTANTS) do
		local name, _, _, _, unlocked = GetCollectibleInfo(collectibleId)
		if unlocked then
			local stringId = "SI_BINDING_NAME_PERSONNALASSISTANT_" .. collectibleId
			if GetString(_G[stringId]) == "" then
				ZO_CreateStringId(stringId, ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, name))
			end
		end
	end
end

local function OnAddonLoaded(_, addonName)
	if addonName == ADDON_NAME then
		CreateBindings()

		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COLLECTIBLE_UPDATED, CreateBindings)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COLLECTION_UPDATED, CreateBindings)
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	end
	
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
