local IST = IST

function IST.SetControlLocation()
	
end

function IST.HideText()
	SummoningControlText:SetHidden(true)
end

local function hideText()
	SummoningControlText:SetHidden(true)
end

function IST.ShowText(text)	
	SummoningControlText:SetText(text)
	ISTControl:SetHidden(false)
	SummoningControlText:SetHidden(false)
	SummoningControlText:SetAlpha(1)
	zo_callLater(function() hideText() end, (IST.GetDelay() * 1000))	
end