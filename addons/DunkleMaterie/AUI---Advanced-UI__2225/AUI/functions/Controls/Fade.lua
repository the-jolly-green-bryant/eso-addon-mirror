AUI.Fade = {}

local function FadeIn(_control, _fadeDuration, _startAlpha, _endAlpha)
	if _control then
		if not _control.fadeAnimation then
			_control.fadeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Fade", _control)
		end
	
		if not _control.isShow and _control.fadeAnimation:IsPlaying() then
			_control.fadeAnimation:Stop()
		end	
	
		if not _control.isShow then
			_control:SetHidden(false)
			if _fadeDuration > 0 then
				_control.fadeAnimation:GetAnimation(1):SetDuration(_fadeDuration)		
				_control.fadeAnimation:GetAnimation(1):SetStartAlpha(_startAlpha)
				_control.fadeAnimation:GetAnimation(1):SetEndAlpha(_endAlpha)							
				_control.fadeAnimation:PlayFromStart()
			else
				_control:SetAlpha(_endAlpha)
			end

			_control.isShow = true
		else
			_control:SetAlpha(_endAlpha)
		end						
	end
end

local function FadeOut(_control, _fadeDuration, _startAlpha, _endAlpha)
	if _control then
		if not _control.fadeAnimation then
			_control.fadeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Fade", _control)
		end
	
		if _control.isShow and _control.fadeAnimation:IsPlaying() then
			_control.fadeAnimation:Stop()
		end
		
		if _control.isShow or _control.isShow == nil and _control:GetAlpha() > 0 then
			if _fadeDuration > 0 then		
				_control.fadeAnimation:GetAnimation(1):SetDuration(_fadeDuration)		
				_control.fadeAnimation:GetAnimation(1):SetStartAlpha(_startAlpha)
				_control.fadeAnimation:GetAnimation(1):SetEndAlpha(_endAlpha)							
				_control.fadeAnimation:PlayFromStart()	
			else
				_control:SetAlpha(_endAlpha)
			end
					
			_control.isShow = false
		end				
	end
end

function AUI.Fade.In(_control, _fadeDuration, _delay, _startAlpha, _endAlpha)
	local fadeDuration = _fadeDuration or 0
	local delay = _delay or 0
	local startAlpha = _startAlpha or 0
	local endAlpha = _endAlpha or 1

	if _control then
		local controlName = _control:GetName()
		EVENT_MANAGER:UnregisterForUpdate("AUI_OnUpdate" .. controlName .. "Fade")
		if delay > 0 then
			EVENT_MANAGER:RegisterForUpdate("AUI_OnUpdate" .. controlName .. "Fade", delay, 
			function()
				FadeIn(_control, fadeDuration, _startAlpha, _endAlpha)
				EVENT_MANAGER:UnregisterForUpdate("AUI_OnUpdate" .. controlName .. "Fade")					
			end)
		else
			FadeIn(_control, fadeDuration, startAlpha, endAlpha)
		end
	end
end

function AUI.Fade.Out(_control, _fadeDuration, _delay, _startAlpha, _endAlpha)
	local fadeDuration = _fadeDuration or 0
	local delay = _delay or 0
	local startAlpha = _startAlpha or _control:GetAlpha()
	local endAlpha = _endAlpha or 0

	if _control then
		local controlName = _control:GetName()
		EVENT_MANAGER:UnregisterForUpdate("AUI_OnUpdate" .. controlName .. "Fade")
		if delay > 0 then
			EVENT_MANAGER:RegisterForUpdate("AUI_OnUpdate" .. controlName .. "Fade", delay, 
			function()
				FadeOut(_control, fadeDuration, startAlpha, endAlpha)			
				EVENT_MANAGER:UnregisterForUpdate("AUI_OnUpdate" .. controlName .. "Fade")
			end)
		else
			FadeOut(_control, fadeDuration, startAlpha, endAlpha)	
		end
	end
end