local TC = TraitCraft

local SMITHING = ZO_SmithingCreation

if IsInGamepadPreferredMode() then
  SMITHING = ZO_GamepadSmithingCreation
end

local function findResearchLineIndex(craftingSkillType, patternName)
	local numResearchLines = GetNumSmithingResearchLines(craftingSkillType)
	for researchLineIndex = 1, numResearchLines do
		local foundResearchLine, _, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
		if foundResearchLine == "Robe & Jerkin" and (patternName == "Robe" or patternName == "Jerkin"  or patternName == "Shirt") then
			return researchLineIndex
		end
		if foundResearchLine == patternName then
			return researchLineIndex
		end
	end
	return nil
end

local function FindLabel(rowControl)
  local child = nil
    for i = 1, rowControl:GetNumChildren() do
      local testchild = rowControl:GetChild(i)
        if testchild:GetType() == CT_LABEL then
            child = testchild
        end
    end
  return child
end

local function OnSmithingCreation(eventCode, craftingType)
  if TC.AV.allCrafterIds and next(TC.AV.allCrafterIds) then
    if TC.AV.allCrafters and TC.AV.allCrafters[craftingType] == TC.currentlyLoggedInCharId then
      ZO_PostHook(SMITHING, "RefreshTraitList", function(self, data)
        local icon = FindLabel(self.traitList.control:GetParent())
        ZO_PostHook(self.traitList, "setupFunction", function(selflist, datalist)
          local selectedTraitData = self.traitList.selectedData
          if selectedTraitData then
            local selectedTrait = selectedTraitData.traitType
            local researchLineIndex = findResearchLineIndex(craftingType, self.patternList.selectedData.patternName)
            local traitIndex = TC:FindTraitIndex(craftingType, researchLineIndex, selectedTrait)
            if icon and researchLineIndex and traitIndex and selectedTrait ~= 0 then
              TC.AddAltNeedIcon(icon, craftingType, researchLineIndex, traitIndex, TOP, BOTTOM, 0, "craftId")
            end
          end
        end)
      end)
    end
  end
end


EVENT_MANAGER:RegisterForEvent("TC_SmithingCreation", EVENT_CRAFTING_STATION_INTERACT, OnSmithingCreation)
