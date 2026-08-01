local isLoaded = false

local originalTargetFrame = nil	
	
local function OnFrameMouseDown(_button, _ctrl, _alt, _shift, _control)
	if _button == 1 and not AUI.Settings.Attributes.lock_windows then
		_control:SetMovable(true)
		_control:StartMoving()
	end
end

local function OnFrameMouseUp(_button, _ctrl, _alt, _shift, _control, _positionData)
	if not AUI.Settings.Attributes.lock_windows then
		_control:SetMovable(false)
		_, _positionData.point, _, _positionData.relativePoint, _positionData.offsetX, _positionData.offsetY = _control:GetAnchor()
	end
end		

local function UpdateTargetFrame()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Target.UpdateTargetFrame")
	end
	--/DebugMessage--

	local difficulty = GetUnitDifficulty(AUI_TARGET_UNIT_TAG)
	
	local templateData = AUI.Attributes.GetCurrentTemplateData()
	if templateData and templateData.attributeData then
		local targetTypes = {AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH, AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH}
		for _, _type in pairs(targetTypes) do
			local targetData = templateData.attributeData[_type]
			if targetData then	
				local difficultyEasy = GetControl(targetData.control, "_DifficultyEasy")
				local difficultyNormal = GetControl(targetData.control, "_DifficultyNormal")
				local difficultyHard = GetControl(targetData.control, "_DifficultyHard")
				local difficultyDeadly = GetControl(targetData.control, "_DifficultyDeadly")
					
				if difficultyEasy then
					if difficulty == MONSTER_DIFFICULTY_EASY then
						difficultyEasy:SetHidden(false)
					else
						difficultyEasy:SetHidden(true)
					end
				end			
					
				if difficultyNormal then
					if difficulty == MONSTER_DIFFICULTY_NORMAL then
						difficultyNormal:SetHidden(false)
					else
						difficultyNormal:SetHidden(true)
					end
				end				
					
				if difficultyHard then
					if difficulty == MONSTER_DIFFICULTY_HARD then
						difficultyHard:SetHidden(false)
					else
						difficultyHard:SetHidden(true)
					end
				end		
					
				if difficultyDeadly then
					if difficulty == MONSTER_DIFFICULTY_DEADLY then
						difficultyDeadly:SetHidden(false)
					else
						difficultyDeadly:SetHidden(true)
					end
				end	
			end			
		end
	end
end	

function AUI.Attributes.Target.OnChanged()	
	if not isLoaded then
		return
	end	

	if originalTargetFrame then
		originalTargetFrame:SetHidden(true)
	end	

	if DoesUnitExist(AUI_TARGET_UNIT_TAG) or AUI.Attributes.IsPreviewShow() then
		AUI.Attributes.ShowFrame(AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH)
		AUI.Attributes.ShowFrame(AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH)
		UpdateTargetFrame()
		AUI.Attributes.Update(AUI_TARGET_UNIT_TAG, true)
	else
		AUI.Attributes.HideFrame(AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH)
		AUI.Attributes.HideFrame(AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH)
	end	
end

function AUI.Attributes.Target.Load()
	originalTargetFrame = ZO_TargetUnitFramereticleover	

	isLoaded = true
end