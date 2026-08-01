local g_isInit = false	
local g_targetData = nil
	
local function OnFrameMouseDown(_button, _ctrl, _alt, _shift, _control)
	if _button == 1 and not AUI.Settings.UnitFrames.lock_windows then
		_control:SetMovable(true)
		_control:StartMoving()
	end
end

local function OnFrameMouseUp(_button, _ctrl, _alt, _shift, _control, _positionData)
	if not AUI.Settings.UnitFrames.lock_windows then
		_control:SetMovable(false)
		_, _positionData.point, _, _positionData.relativePoint, _positionData.offsetX, _positionData.offsetY = _control:GetAnchor()
	end
end		

local function ShowTargetFrame()
	if g_targetData then
		local difficulty = GetUnitDifficulty(AUI_TARGET_UNIT_TAG)
	
		for frameType, data in pairs(g_targetData.frameData) do
			if data and data.control and data.control.settings and data.control.settings.display and AUI.UnitFrames.IsTargetHealth(frameType) then			
				local difficultyEasy = GetControl(data.control, "_DifficultyEasy")
				local difficultyNormal = GetControl(data.control, "_DifficultyNormal")
				local difficultyHard = GetControl(data.control, "_DifficultyHard")
				local difficultyDeadly = GetControl(data.control, "_DifficultyDeadly")
					
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

				AUI.Fade.In(data.control, 0, 0, 0, data.control.settings.opacity)			
			end	
		end
	end
	
	AUI.UnitFrames.Update(AUI_TARGET_UNIT_TAG, true)
end	

local function HideTargetFrame()
	if g_targetData then
		for frameType, data in pairs(g_targetData.frameData) do
			if data then
				AUI.Fade.Out(data.control)
			end
		end
	end	
end

function AUI.UnitFrames.Target.OnChanged()	
	if not g_isInit then
		return
	end	

	if ZO_TargetUnitFramereticleover then
		ZO_TargetUnitFramereticleover:SetHidden(true)
	end

	if DoesUnitExist(AUI_TARGET_UNIT_TAG) or AUI.UnitFrames.IsPreviewShow() then	
		ShowTargetFrame()
	else
		HideTargetFrame()			
	end	
end

function AUI.UnitFrames.Target.Load()
	g_isInit = true	
	g_targetData = AUI.UnitFrames.GetActiveTargetTemplateData()
	AUI.UnitFrames.Target.OnChanged()
end