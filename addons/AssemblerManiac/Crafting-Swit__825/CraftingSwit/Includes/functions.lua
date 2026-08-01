--[[

	GLOBAL FUNCTIONS

]]--

function CraftingSwit.ClearBoxes()
	local clearidx = 1
	while CraftingSwit.textbox[clearidx] do
		CraftingSwit.textbox[clearidx]:SetText("")
		CraftingSwit.textbox[clearidx]:SetHandler()
		clearidx = clearidx + 1
	end
end

-- For KeyBind
function CraftingSwit.ToggleHidden()
	local isHidden = CraftingSwitMain:IsHidden()
	if isHidden == true then
		CraftingSwitMain:SetHidden(false)
	else
		CraftingSwitMain:SetHidden(true)
	end
end


-- Background
-- Transparency
function CraftingSwit.GetBgAlpha()
	return CraftingSwit.SavedVars.BgAlpha
end
function CraftingSwit.SetBgAlpha(newAlpha)
	CraftingSwit.SavedVars.BgAlpha = newAlpha
	CraftingSwitMain:SetAlpha(newAlpha/100)
	CraftingSwit.SavedVars.Preset = "Custom"
end

-- Width
function CraftingSwit.GetBgWidth()
	local ret = 275
	if CraftingSwit.SavedVars and CraftingSwit.SavedVars.BgWidth then
		ret = tonumber(CraftingSwit.SavedVars.BgWidth)
	end
	return ret
end
function CraftingSwit.SetBgWidth(newWidth)
	CraftingSwit.SavedVars.BgWidth = newWidth
	CraftingSwitBg:SetDimensionConstraints(newWidth,-1,newWidth,-1)
	CraftingSwit.SavedVars.Preset = "Custom"
end

function CraftingSwit.GetTextFont()
	local ret = "Univers 57"
	if CraftingSwit.SavedVars and CraftingSwit.SavedVars.TextFont then
		ret = CraftingSwit.SavedVars.TextFont
	end
	return ret
end

function CraftingSwit.GetTextStyle()
	local ret = "soft-shadow-thin"
	if CraftingSwit.SavedVars and CraftingSwit.SavedVars.TextStyle then
		ret = CraftingSwit.SavedVars.TextStyle
	end
	return ret
end

function CraftingSwit.GetTextColour()
	local ret = { ["r"]=1, ["g"]=1, ["b"]=1, ["a"]=0.950820 }
	if CraftingSwit.SavedVars and CraftingSwit.SavedVars.TextColor then
		ret = CraftingSwit.SavedVars.TextColor
	end
	return ret
end

-- Width
function CraftingSwit.GetTextPadding()
	local ret = 24
	if CraftingSwit.SavedVars and CraftingSwit.SavedVars.TextPadding then
		ret = tonumber(CraftingSwit.SavedVars.TextPadding)
	end
	return ret
end
function CraftingSwit.SetTextPadding(newWidth)
	CraftingSwit.SavedVars.TextPadding = newWidth
	CraftingSwit.SavedVars.Preset = "Custom"
end

function CraftingSwit.GetBgPadding()
	 local ret = (275 - 24)
	 if CraftingSwit.SavedVars and CraftingSwit.SavedVars.TextPadding and CraftingSwit.SavedVars.BgWidth then
		ret = tonumber(CraftingSwit.GetBgWidth) - tonumber(CraftingSwit.SavedVars.TextPadding)
	 end
	 return ret
 end

-- Position
function CraftingSwit.GetPositionLockOption()
	return CraftingSwit.SavedVars.PositionLockOption
end

function CraftingSwit.SetPositionLockOption(newOpt)
	CraftingSwit.SavedVars.PositionLockOption = newOpt
	CraftingSwitMain:SetMouseEnabled(not newOpt)
	CraftingSwitMain:SetMovable(not newOpt)
end

-- language
function CraftingSwit.GetLanguage()
	return CraftingSwit.SavedVars.Language
end

function CraftingSwit.SetLanguage(newLang)
	CraftingSwit.SavedVars.Language = newLang
	ReloadUI()
end

-- Color
function CraftingSwit.GetBgOption()
	return CraftingSwit.SavedVars.BgOption
end
function CraftingSwit.SetBgOption(newOpt)
	CraftingSwit.SavedVars.BgOption = newOpt
	if newOpt == true then
		CraftingSwitBg:SetColor(CraftingSwit.SavedVars.BgColor.r,CraftingSwit.SavedVars.BgColor.g,CraftingSwit.SavedVars.BgColor.b,CraftingSwit.SavedVars.BgColor.a)
	else
		CraftingSwitBg:SetColor(0,0,0,0)
	end
	CraftingSwit.SavedVars.Preset = "Custom"
end

function CraftingSwit.GetBgColor()
	return CraftingSwit.SavedVars.BgColor.r, CraftingSwit.SavedVars.BgColor.g, CraftingSwit.SavedVars.BgColor.b, CraftingSwit.SavedVars.BgColor.a
end
function CraftingSwit.SetBgColor(r,g,b,a)
	CraftingSwit.SavedVars.BgColor.r = r
	CraftingSwit.SavedVars.BgColor.g = g
	CraftingSwit.SavedVars.BgColor.b = b
	CraftingSwit.SavedVars.BgColor.a = a
	CraftingSwitBg:SetColor(r,g,b,a)
	CraftingSwit.SavedVars.Preset = "Custom"
end

function CraftingSwit.GetHideCompleted()
	return CraftingSwit.SavedVars.HideCompleted
end
function CraftingSwit.SetHideCompleted(value)
	CraftingSwit.SavedVars.HideCompleted = value
end

