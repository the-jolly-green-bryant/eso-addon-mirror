local AGS = AwesomeGuildStore

local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID



local UnknownOnAltsFilter = MultiChoiceFilterBase:Subclass()
AGS.class.UnknownOnAltsFilter = UnknownOnAltsFilter

function UnknownOnAltsFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function UnknownOnAltsFilter:Initialize()

	local crafticons = {}
	for i = 1, #AGS_UOAF.savedVars.crafters do
		crafticons[i] = {
			id = AGS_UOAF.savedVars.crafters[i],
			label = AGS_UOAF.charid2charnames[AGS_UOAF.savedVars.crafters[i]],
			icon = "EsoUI/Art/CharacterCreate/charactercreate_faceicon_%s.dds",
		}
	end
	MultiChoiceFilterBase.Initialize(self, FILTER_ID.UNKNOWN_ON_ALTS_FILTER, AGS.class.FilterBase.GROUP_LOCAL, ("Unknown On Alts"), crafticons )
    self:SetEnabledSubcategories({
        [SUB_CATEGORY_ID.CONSUMABLE_MOTIF] = true,
		[SUB_CATEGORY_ID.CONSUMABLE_RECIPE] = true,
    })
end


function UnknownOnAltsFilter:SetSelected(value, selected, silent)

	MultiChoiceFilterBase.SetSelected(self, value, selected, silent)
	if AGS_UOAF.currentselection[value.id] and not selected then 
		AGS_UOAF.currentselection[value.id] = nil 
		if AGS_UOAF.highestorderofselected == AGS_UOAF.characterorder[value.id] then
			AGS_UOAF.highestorderofselected = 0 
			for id, selected in pairs(AGS_UOAF.currentselection) do
				if AGS_UOAF.characterorder[id] > AGS_UOAF.highestorderofselected then AGS_UOAF.highestorderofselected = AGS_UOAF.characterorder[id] end
			end
		end
	end
	if not AGS_UOAF.currentselection[value.id] and selected then 
		AGS_UOAF.currentselection[value.id] = true
		if AGS_UOAF.highestorderofselected < AGS_UOAF.characterorder[value.id] then
			AGS_UOAF.highestorderofselected = AGS_UOAF.characterorder[value.id]
		end
	end
end


function UnknownOnAltsFilter:SetValues(selection)
 
	local changed = false
    local currentSelection = self.selection
    for value, state in pairs(selection) do
        if(currentSelection[value] ~= state) then
            changed = true
        end
        self:SetSelected(value, state, SILENT)
    end
    self:HandleChange(currentSelection)
end


function UnknownOnAltsFilter:Reset(silent)

	AGS_UOAF.currentselection = {}
	AGS_UOAF.highestorderofselected = 0
	MultiChoiceFilterBase.Reset(self, silent)	
end

function UnknownOnAltsFilter:FilterLocalResult(itemData)

	local id = 0
	if self.count > 0 then
		local knownstatus = LibCharacterKnowledge.GetItemKnowledgeList(itemData.itemLink, nil)
		local i = 1
		local foundcrafter = false
		while knownstatus[i] and not foundcrafter and  i <= AGS_UOAF.highestorderofselected do 
			if knownstatus[i].knowledge == LibCharacterKnowledge.KNOWLEDGE_UNKNOWN then
				for value, selected in pairs(AGS_UOAF.currentselection) do
					if knownstatus[i].id == value then 
						foundcrafter = true 
						id = value
						break
					end
				end
			end
			i = i + 1
		end
	end
    local value = self.valueById[id]
    return self.localSelection[value]
end



function AGS_UOAF.initAGS()

   AGS:RegisterFilter(UnknownOnAltsFilter:New())
   AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_ID.UNKNOWN_ON_ALTS_FILTER))
end