
local function OnLoad(eventCode, addOnName)
	if addOnName ~= "SpentSkillPoints" then
		return
	end
	
	local origLineSetup = SKILLS_WINDOW.skillLinesTree.templateInfo["ZO_SkillsNavigationEntry"].setupFunction
	SKILLS_WINDOW.skillLinesTree.templateInfo["ZO_SkillsNavigationEntry"].setupFunction = function(node, control, skillLineData, open, ...)
		origLineSetup(node, control, skillLineData, open, ...)
		if skillLineData.isSubclassingNode ~= true then
			control:SetText(skillLineData:GetFormattedNameWithNumPointsAllocated())
			
			if not control.levelLabel then
				control.levelLabel = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_SelectableLabel")
				control.levelLabel:SetFont("ZoFontHeader")
				control.levelLabel:SetAnchor(RIGHT, control:GetNamedChild("StatusIcon"), LEFT)
				control.levelLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			end
			
			if skillLineData.GetCurrentRank then
				control.levelLabel:SetText(skillLineData:GetCurrentRank())
			end
		end
		
	end
	
	local origHeaderSetup = SKILLS_WINDOW.skillLinesTree.templateInfo["ZO_SkillIconHeader"].setupFunction
	SKILLS_WINDOW.skillLinesTree.templateInfo["ZO_SkillIconHeader"].setupFunction = function(node, control, skillTypeData, open, ...)
		origHeaderSetup(node, control, skillTypeData, open, ...)
		numPointsAllocated = SKILL_POINT_ALLOCATION_MANAGER:GetNumPointsAllocatedInSkillType(skillTypeData)
		control.text:SetText(zo_strformat(SI_SKILLS_ENTRY_LINE_NAME_FORMAT_WITH_ALLOCATED_POINTS, skillTypeData:GetName(), numPointsAllocated))
	end
	
	function SKILL_POINT_ALLOCATION_MANAGER:GetNumPointsAllocatedInSkillType(skillTypeData)
		local total = 0
		for _, skillLineData in ipairs(skillTypeData.orderedSkillLines) do
			total = total + SKILL_POINT_ALLOCATION_MANAGER:GetNumPointsAllocatedInSkillLine(skillLineData)
		end
		return total
	end
	
	function SKILL_POINT_ALLOCATION_MANAGER:GetNumPointsAllocated()
		local total = 0
		for _, skillTypeData in SKILLS_DATA_MANAGER:SkillTypeIterator() do
			total = total + self:GetNumPointsAllocatedInSkillType(skillTypeData)
		end
		return total
	end
	
	function SKILL_POINT_ALLOCATION_MANAGER:GetTotalNumSkillPoints()
		return self:GetAvailableSkillPoints() + self:GetNumPointsAllocated()
	end
	
	local oldRefresh = SKILLS_WINDOW.RefreshSkillPointInfo
	SKILLS_WINDOW.RefreshSkillPointInfo = function(self, ...)
		oldRefresh(self, ...)
		
		local availablePoints = SKILL_POINT_ALLOCATION_MANAGER:GetAvailableSkillPoints()
		self.availablePointsLabel:SetText(zo_strformat(SI_SKILLS_POINTS_TO_SPEND, availablePoints) .. "/" .. SKILL_POINT_ALLOCATION_MANAGER:GetTotalNumSkillPoints())
	end
end

EVENT_MANAGER:RegisterForEvent("SpentSkillPoints", EVENT_ADD_ON_LOADED, OnLoad)