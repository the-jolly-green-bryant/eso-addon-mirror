

--=====================================--
--======== XML MOVE & RESIZE FUNCTIONS	 ==========--
--=====================================--
function EmoteIt_OnResizeStart_MainWin(self)
	EVENT_MANAGER:RegisterForUpdate("EmoteIt_Resize_MainWin", 100, function()
		ZO_ScrollList_Commit(EmoteIt.scrollListMain)
	end)
end
function EmoteIt_OnResizeStop_MainWin(self)
	EVENT_MANAGER:UnregisterForUpdate("EmoteIt_Resize_MainWin")
	
	EmoteIt.sv.mainWinSettings.width 	= self:GetWidth()
	EmoteIt.sv.mainWinSettings.height	= self:GetHeight()
end
function EmoteIt_OnMoveStop_MainWin(self)
	EmoteIt.sv.mainWinSettings.offsetX	= self:GetLeft()
	EmoteIt.sv.mainWinSettings.offsetY	= self:GetTop()
end

function EmoteIt_Toggle_Window()
	local shouldHide = not EmoteIt.mainWin:IsHidden()
	if shouldHide then
		EmoteIt.mainWin:SetHidden(true)
		EmoteIt.triggerWin:SetHidden(true)
		EmoteIt.sv.mainWinSettings.hidden = true
	else
		EmoteIt.mainWin:SetHidden(false)
		EmoteIt.sv.mainWinSettings.hidden = false
		
		-- If somethings selected show trigger window:
		if ZO_ScrollList_GetSelectedData(EmoteIt.scrollListMain) then
			EmoteIt.triggerWin:SetHidden(false)
		end
	end
end

