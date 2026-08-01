local util = AdvancedFilters.util
local function GetFilterCallbackForResearch(researchType)
	return function(slot, slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end
		local data
		if slot.dataEntry then
			data = slot.dataEntry.data.researchAssistant
		else
			return false
		end
		if data == researchType then
			return true
		end
		return false
	end
end

local ResearchAssistantDropdownCallbacks = {
	[1] = {name = "Researchable", filterCallback = GetFilterCallbackForResearch("researchable")},
	[2] = {name = "Duplicate", filterCallback = GetFilterCallbackForResearch("duplicate")},
	[3] = {name = "Known", filterCallback = GetFilterCallbackForResearch("known")},
}

local en = {
	["Researchable"] = "Researchable",
	["Duplicate"] = "Duplicate",
	["Known"] = "Known",
}
local de = {
	["Researchable"] = "Analysierbar",
	["Duplicate"] = "Doppelt",
	["Known"] = "Bekannt",
}
local fr = {
	["Researchable"] = "Recherchable",
	["Duplicate"] = "Double",
	["Known"] = "Connu",
}

local filterInformation = {
	callbackTable = ResearchAssistantDropdownCallbacks,
	filterType = ITEMFILTERTYPE_WEAPONS,
	subfilters = {
		[1] = "All",
	},
	enStrings = en,
	deStrings = de,
	frStrings = fr,
}

AdvancedFilters_RegisterFilter(filterInformation)

filterInformation = {
	callbackTable = ResearchAssistantDropdownCallbacks,
	filterType = ITEMFILTERTYPE_ARMOR,
	subfilters = {
		[1] = "Body",
		[2] = "Shield",
	},
	enStrings = en,
	deStrings = de,
	frStrings = fr,
}

AdvancedFilters_RegisterFilter(filterInformation)
