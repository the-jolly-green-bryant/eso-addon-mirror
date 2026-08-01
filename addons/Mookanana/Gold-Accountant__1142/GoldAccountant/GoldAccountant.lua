GoldAccountant = {}
 
GoldAccountant.name = "GoldAccountant"
GoldAccountant.sessionStartGold=0
GoldAccountant.sessionStartTime=0
GoldAccountant.income=0
GoldAccountant.expenditure=0
GoldAccountant.diff=0
GoldAccountant.time=0
GoldAccountant.gph=0
GoldAccountant.highgph=0
GoldAccountant.prevFrameTime=0

function GoldAccountant:Initialize()
	GoldAccountant.sessionStartGold=GetCurrentMoney()
	GoldAccountant.sessionStartTime=GetTimeStamp()
	GoldAccountant.income=0
	GoldAccountant.expenditure=0
	GoldAccountant.diff=0
	GoldAccountant.time=GetTimeStamp()
	GoldAccountant.gph=0
	GoldAccountant.highgph=0
	GoldAccountant.prevFrameTime=0
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MONEY_UPDATE, self.OnPlayerMoneyUpdate)
	self.savedVariables = ZO_SavedVars:New("GoldAccountantSavedVariables", 1, nil, {})
	self:RestorePosition()
	
	GoldAccountant:UpdateSessionStartText()
	GoldAccountant:UpdateIncome()
	GoldAccountant:UpdateExpenditure()
	GoldAccountant:UpdateTime()
	GoldAccountant:UpdateGPH()
	GoldAccountant:UpdateBalance()
	
	GoldAccountantIndicatorGPHText:SetColor(1,1,1,1)
	--GoldAccountantIndicatorHighGPHText:SetColor(1,1,1,1)
end

SLASH_COMMANDS["/gareset"] = Reset

function GoldAccountant.Reset()
	GoldAccountant.sessionStartGold=GetCurrentMoney()
	GoldAccountant.sessionStartTime=GetTimeStamp()
	GoldAccountant.income=0
	GoldAccountant.expenditure=0
	GoldAccountant.diff=0
	GoldAccountant.time=GetTimeStamp()
	GoldAccountant.gph=0
	GoldAccountant.highgph=0
	GoldAccountant.prevFrameTime=0
	
	GoldAccountant:UpdateSessionStartText()
	GoldAccountant:UpdateIncome()
	GoldAccountant:UpdateExpenditure()
	GoldAccountant:UpdateTime()
	GoldAccountant:UpdateGPH()
	GoldAccountant:UpdateBalance()
	
	GoldAccountantIndicatorTimeText:SetText("0s")
	GoldAccountantIndicatorGPHText:SetColor(1,1,1,1)
	GoldAccountantIndicatorGPHText:SetText(string.format(string.format("%.2f", GoldAccountant.gph) .. "g"))
	GoldAccountantIndicatorIncomeText:SetText("0g")
	GoldAccountantIndicatorExpenditureText:SetText("0g")
end
 
function GoldAccountant.OnAddOnLoaded(event, addonName)
  if addonName == GoldAccountant.name then
    GoldAccountant:Initialize()
  end
end

function GoldAccountant.OnUpdate()
	GoldAccountant.time=GetDiffBetweenTimeStamps(GetTimeStamp(), GoldAccountant.sessionStartTime)
	
	if (GoldAccountant.time==GoldAccountant.prevFrameTime) then
		do return end
	end

	GoldAccountant:UpdateTime()
	GoldAccountant:UpdateGPH()
		
	GoldAccountant.prevFrameTime=GoldAccountant.time
end

function GoldAccountant.OnPlayerMoneyUpdate(eventCode, newMoney, oldMoney, reason)
	GoldAccountant.diff=newMoney - oldMoney
	
	if GoldAccountant.diff<0 then
		GoldAccountant:UpdateExpenditure(GoldAccountant.diff)
	elseif GoldAccountant.diff>0 then
		GoldAccountant:UpdateIncome(GoldAccountant.diff)
	end

	GoldAccountant:UpdateBalance()
end

function GoldAccountant.UpdateTime()
	if (GoldAccountant.time<60) then
		GoldAccountantIndicatorTimeText:SetText(GoldAccountant.time .. "s")
	elseif (GoldAccountant.time<3600) then
		local d1=GoldAccountant.time%60
		local d2=(GoldAccountant.time-d1)/60
		GoldAccountantIndicatorTimeText:SetText(d2 .. "m " ..d1 .. "s")
	elseif (GoldAccountant.time<86400) then
		local d1=GoldAccountant.time%60
		local d2=(GoldAccountant.time-d1)/60
		local d3=d2%60
		local d4=(d2-d3)/60
		GoldAccountantIndicatorTimeText:SetText(d4 .. "h ".. d3 .. "m " ..d1 .. "s")
	elseif (GoldAccountant.time>=86400) then
		local d1=GoldAccountant.time%60
		local d2=(GoldAccountant.time-d1)/60
		local d3=d2%60
		local d4=(d2-d3)/60
		local d5=d4%24
		local d6=(d4-d5)/24
		GoldAccountantIndicatorTimeText:SetText(d6 .. "d " .. d5 .. "h ".. d3 .. "m " ..d1 .. "s")
	end
end

function GoldAccountant.UpdateGPH()
	local d1=GetCurrentMoney()-GoldAccountant.sessionStartGold
	local d2=(d1/GoldAccountant.time)*60
	
	if (d1==0) then
		GoldAccountant.gph=0
		GoldAccountant.highgph=0
		GoldAccountantIndicatorGPHText:SetText(string.format(string.format("%.2f", GoldAccountant.gph) .. "g"))
		--GoldAccountantIndicatorHighGPHText:SetText(string.format(GoldAccountant.highgph))
	elseif (d1>0) then
		GoldAccountantIndicatorGPHText:SetColor(0.341,1,0,1)
		GoldAccountant.gph=GoldAccountant.Round(d2, 2)
		GoldAccountantIndicatorGPHText:SetText(string.format(string.format("%.2f", GoldAccountant.gph) .. "g"))
	elseif (d1<0) then
		GoldAccountantIndicatorGPHText:SetColor(1,0.184,0,1)
		GoldAccountant.gph=GoldAccountant.Round(d2, 2)
		GoldAccountantIndicatorGPHText:SetText(string.format(string.format("%.2f", GoldAccountant.gph) .. "g"))
	end

	--[[
	if (GoldAccountant.gph>GoldAccountant.highgph) then
		GoldAccountant.highgph=GoldAccountant.gph
		GoldAccountantIndicatorHighGPHText:SetText(string.format(GoldAccountant.highgph))
		if (GoldAccountant.highgph>0) then
			GoldAccountantIndicatorHighGPHText:SetColor(0.341,1,0,1)
		elseif (GoldAccountant.highgph<0) then
			GoldAccountantIndicatorHighGPHText:SetColor(1,0.184,0,1)
		end
	end
	--]]
end

function GoldAccountant.Round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function GoldAccountant.UpdateBalance()
	GoldAccountantIndicatorBalanceText:SetText(string.format(GetCurrentMoney() .. "g"))
end

function GoldAccountant.UpdateIncome()
	GoldAccountant.income=GoldAccountant.income+GoldAccountant.diff
	GoldAccountantIndicatorIncomeText:SetText(string.format(GoldAccountant.income .. "g"))
end

function GoldAccountant.UpdateSessionStartText()
	GoldAccountantIndicatorSessionStartText:SetText(string.format(GoldAccountant.sessionStartGold .. "g"))
end

function GoldAccountant.UpdateExpenditure()
	GoldAccountant.expenditure=GoldAccountant.expenditure+GoldAccountant.diff
	GoldAccountantIndicatorExpenditureText:SetText(string.format(GoldAccountant.expenditure .. "g"))
end

function GoldAccountant.OnIndicatorMoveStop()
  GoldAccountant.savedVariables.left = GoldAccountantIndicator:GetLeft()
  GoldAccountant.savedVariables.top = GoldAccountantIndicator:GetTop()
end

function GoldAccountant:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
 
  GoldAccountantIndicator:ClearAnchors()
  GoldAccountantIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function GoldAccountant.ShowHide()
  local b = GoldAccountantIndicator:IsHidden()
  GoldAccountantIndicator:SetHidden(not b)
end

EVENT_MANAGER:RegisterForEvent(GoldAccountant.name, EVENT_ADD_ON_LOADED, GoldAccountant.OnAddOnLoaded)

ZO_CreateStringId("SI_BINDING_NAME_GA_SHOWHIDE", "Show/Hide")