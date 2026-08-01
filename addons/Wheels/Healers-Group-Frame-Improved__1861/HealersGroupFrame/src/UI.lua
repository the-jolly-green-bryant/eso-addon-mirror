HGF.UI = {}
HGF.UI.unitFrames = {}

HGF.UI.textSpacing = 3
HGF.UI.leaderWidth = 20
HGF.UI.stealthWidth = 32

function HGF.UI.AddUnitFrame(unitTag)
	if HGF.UI.unitFrames[unitTag] ~= nil then
		return end

	local unitFrame = {}

	unitFrame.main = WINDOW_MANAGER:CreateControl("HGF_Unit_Main"..unitTag, HGF.UI.MainWindow, CT_CONTROL)
	unitFrame.main:SetMouseEnabled(true)
	unitFrame.main:SetMovable(true)
	unitFrame.main:SetHidden(true)
	unitFrame.main.unitTag = unitTag
	unitFrame.main:SetHandler("OnMouseUp", function(self)
			x, y = self:GetCenter()
			HGF.UnitDropped(self.unitTag, x, y)
		end)

	unitFrame.bg = WINDOW_MANAGER:CreateControl("HGF_Unit_BG"..unitTag, unitFrame.main, CT_BACKDROP)
	unitFrame.bg:SetAnchorFill(unitFrame.main)
	unitFrame.bg:SetCenterColor(0, 0, 0, 1)
	unitFrame.bg:SetEdgeColor(1, 1, 1, 0)
	unitFrame.bg:SetDrawLayer(10)

	unitFrame.hpBar = WINDOW_MANAGER:CreateControl("HGF_Unit_HpBar"..unitTag, unitFrame.main, CT_STATUSBAR)
	unitFrame.hpBar:SetAnchorFill(unitFrame.main)
	unitFrame.hpBar:SetMinMax(0, 100)
	unitFrame.hpBar:SetValue(100)
	unitFrame.hpBar:SetDrawLayer(8)

	unitFrame.shield = WINDOW_MANAGER:CreateControl("HGF_Unit_Shield"..unitTag, unitFrame.main, CT_STATUSBAR)
	unitFrame.shield:SetAnchorFill(unitFrame.main)
	unitFrame.shield:SetMinMax(0, 100)
	unitFrame.shield:SetValue(0)
	unitFrame.shield:SetDrawLayer(6)

	unitFrame.dead = WINDOW_MANAGER:CreateControl("HGF_Unit_Dead"..unitTag, unitFrame.main, CT_TEXTURE)
	unitFrame.dead:SetAnchorFill(unitFrame.main)
	unitFrame.dead:SetColor(0.6, 0.6, 0.6, 1)
	unitFrame.dead:SetTexture("/HealersGroupFrame/art/dead.dds")
	unitFrame.dead:SetHidden(true)
	unitFrame.dead:SetDrawLayer(4)

	unitFrame.offline = WINDOW_MANAGER:CreateControl("HGF_Unit_Offline"..unitTag, unitFrame.main, CT_TEXTURE)
	unitFrame.offline:SetAnchorFill(unitFrame.main)
	unitFrame.offline:SetColor(0.6, 0.6, 0.6, 1)
	unitFrame.offline:SetTexture("/HealersGroupFrame/art/offline.dds")
	unitFrame.offline:SetHidden(true)
	unitFrame.offline:SetDrawLayer(4)

	unitFrame.leader = WINDOW_MANAGER:CreateControl("HGF_Unit_Leader"..unitTag, unitFrame.main, CT_TEXTURE)
	unitFrame.leader:SetAnchor(TOPLEFT, unitFrame.main, TOPLEFT, 0, 0)
	unitFrame.leader:SetDimensions(0, HGF.UI.leaderWidth)
	unitFrame.leader:SetColor(0.9, 0.9, 0.9, 1)
	unitFrame.leader:SetTexture("/esoui/art/lfg/lfg_leader_icon.dds")
	unitFrame.leader:SetDrawLayer(2)
	unitFrame.leader:SetHidden(true)

	unitFrame.stealth = WINDOW_MANAGER:CreateControl("HGF_Unit_Stealth"..unitTag, unitFrame.main, CT_TEXTURE)
	unitFrame.stealth:SetAnchor(TOPRIGHT, unitFrame.main, TOPRIGHT, 0, 0)
	unitFrame.stealth:SetDimensions(0, HGF.UI.stealthWidth)
	unitFrame.stealth:SetColor(0.9, 0.9, 0.9, 1)
	unitFrame.stealth:SetTexture("/esoui/art/stealth/stealth_64.dds")
	unitFrame.stealth:SetTextureCoords(32.1 / 64, 32.9 / 64, 0.2, 1)
	unitFrame.stealth:SetDrawLayer(2)

	unitFrame.text = {}
	unitFrame.text[1] = WINDOW_MANAGER:CreateControl("HGF_Unit_HP_Text1"..unitTag, unitFrame.main, CT_LABEL)
	unitFrame.text[1]:SetAnchor(TOPLEFT, unitFrame.leader, TOPRIGHT, HGF.UI.textSpacing, 0)
	unitFrame.text[1]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	unitFrame.text[1]:SetVerticalAlignment(TEXT_ALIGN_TOP)
	unitFrame.text[1]:SetDrawLayer(2)

	unitFrame.text[2] = WINDOW_MANAGER:CreateControl("HGF_Unit_HP_Text2"..unitTag, unitFrame.main, CT_LABEL)
	unitFrame.text[2]:SetAnchor(TOPRIGHT, unitFrame.stealth, TOPLEFT, -HGF.UI.textSpacing, 0)
	unitFrame.text[2]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	unitFrame.text[2]:SetVerticalAlignment(TEXT_ALIGN_TOP)
	unitFrame.text[2]:SetDrawLayer(2)

	unitFrame.text[3] = WINDOW_MANAGER:CreateControl("HGF_Unit_HP_Text3"..unitTag, unitFrame.main, CT_LABEL)
	unitFrame.text[3]:SetAnchor(BOTTOMLEFT, unitFrame.main, BOTTOMLEFT, HGF.UI.textSpacing, 0)
	unitFrame.text[3]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	unitFrame.text[3]:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
	unitFrame.text[3]:SetDrawLayer(2)

	unitFrame.text[4] = WINDOW_MANAGER:CreateControl("HGF_Unit_HP_Text4"..unitTag, unitFrame.main, CT_LABEL)
	unitFrame.text[4]:SetAnchor(BOTTOMRIGHT, unitFrame.main, BOTTOMRIGHT, -HGF.UI.textSpacing, 0)
	unitFrame.text[4]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	unitFrame.text[4]:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
	unitFrame.text[4]:SetDrawLayer(2)

	HGF.UI.unitFrames[unitTag] = unitFrame
end

function HGF.UI.UpdateTextWidth(unitTag)
	local nameText = nil
	local otherText = nil
	local newWidth = HGF.activeVars["frameWidth"]

	if HGF.activeVars["textType"][1] == HGF.textName or HGF.activeVars["textType"][1] == HGF.textAtName then
		nameText = HGF.UI.unitFrames[unitTag].text[1]
		otherText = HGF.UI.unitFrames[unitTag].text[2]
		newWidth = newWidth - HGF.UI.unitFrames[unitTag].leader:GetWidth()
		newWidth = newWidth - HGF.UI.unitFrames[unitTag].stealth:GetWidth()
	elseif HGF.activeVars["textType"][2] == HGF.textName or HGF.activeVars["textType"][2] == HGF.textAtName then
		nameText = HGF.UI.unitFrames[unitTag].text[2]
		otherText = HGF.UI.unitFrames[unitTag].text[1]
		newWidth = newWidth - HGF.UI.unitFrames[unitTag].leader:GetWidth()
		newWidth = newWidth - HGF.UI.unitFrames[unitTag].stealth:GetWidth()
	elseif HGF.activeVars["textType"][3] == HGF.textName or HGF.activeVars["textType"][3] == HGF.textAtName then
		nameText = HGF.UI.unitFrames[unitTag].text[3]
		otherText = HGF.UI.unitFrames[unitTag].text[4]
	elseif HGF.activeVars["textType"][4] == HGF.textName or HGF.activeVars["textType"][4] == HGF.textAtName then
		nameText = HGF.UI.unitFrames[unitTag].text[4]
		otherText = HGF.UI.unitFrames[unitTag].text[3]
	end
	if nameText ~= nil then
		newWidth = newWidth - otherText:GetTextWidth() - (HGF.UI.textSpacing * 3)
		if newWidth < 0 then
			newWidth = 0
		end
		nameText:SetWidth(newWidth)
	end
end

function HGF.UI.SetText(unitTag, nbr, text)
	HGF.UI.unitFrames[unitTag].text[nbr]:SetText(text)
	HGF.UI.UpdateTextWidth(unitTag)
end

function HGF.UI.ApplySettings()
	local frameWidth = HGF.activeVars["frameWidth"]
	local frameHeight = HGF.activeVars["frameHeight"]
	local anchor = HGF.UI.GetAnchorPoint()
	HGF.UI.SetMainAnchorPos(HGF.activeVars["MW_Pos"][1], HGF.activeVars["MW_Pos"][2])
	HGF.UI.MainAnchorBG:ClearAnchors()
	HGF.UI.MainAnchorBG:SetAnchor(anchor, HGF.UI.MainAnchor, anchor, 0, 0)
	for unitTag, unitFrame in pairs(HGF.UI.unitFrames) do
		unitFrame.main:SetDimensions(frameWidth, frameHeight)
		unitFrame.hpBar:SetColor(HGF.activeVars["healthBarColor"][1], HGF.activeVars["healthBarColor"][2], HGF.activeVars["healthBarColor"][3], 1)
		unitFrame.hpBar:SetTexture(HGF.activeVars["frame_texture"])
		unitFrame.shield:SetColor(HGF.activeVars["shieldColor"][1], HGF.activeVars["shieldColor"][2], HGF.activeVars["shieldColor"][3], 0.5)
		unitFrame.shield:SetTexture(HGF.activeVars["frame_texture"])
		unitFrame.shield:SetHidden(not HGF.activeVars["showShieldIndicator"])
		if not HGF.activeVars["showLeaderIcon"] then
			unitFrame.leader:SetWidth(0)
			unitFrame.leader:SetHidden(true)
		end
		if not HGF.activeVars["showStealthIndicator"] then
			unitFrame.stealth:SetWidth(0)
			unitFrame.stealth:SetHidden(true)
		end
		for i = 1, 4, 1 do
			unitFrame.text[i]:SetColor(HGF.activeVars["textColor"][1], HGF.activeVars["textColor"][2], HGF.activeVars["textColor"][3], 1)
			unitFrame.text[i]:SetFont(HGF.activeVars["font"])
			unitFrame.text[i]:SetWidth(frameWidth)
			unitFrame.text[i]:SetHeight(unitFrame.text[i]:GetFontHeight())
			unitFrame.text[i]:SetHidden(HGF.activeVars["textType"][i] == HGF.textNone)
			if HGF.activeVars["textType"][i] == HGF.textNone then
				HGF.UI.SetText(unitTag, i, "")
			end
		end
		HGF.UI.UpdateTextWidth(unitTag)
	end
end

function HGF.UI.LayoutFrames(unitTagIterator)
	local nbrFrames = 0
	local anchorPoint = TOPLEFT
	local xGrow = 1
	local yGrow = 1

	if HGF.activeVars["growDirV"] == "down" and HGF.activeVars["growDirH"] == "right" then
		anchorPoint = TOPLEFT
		xGrow = 1
		yGrow = 1
	elseif HGF.activeVars["growDirV"] == "up" and HGF.activeVars["growDirH"] == "right" then
		anchorPoint = BOTTOMLEFT
		xGrow = 1
		yGrow = -1
	elseif HGF.activeVars["growDirV"] == "down" and HGF.activeVars["growDirH"] == "left" then
		anchorPoint = TOPRIGHT
		xGrow = -1
		yGrow = 1
	elseif HGF.activeVars["growDirV"] == "up" and HGF.activeVars["growDirH"] == "left" then
		anchorPoint = BOTTOMRIGHT
		xGrow = -1
		yGrow = -1
	else
		d("HGF.UI.LayoutFrames: Could not determine anchor point!")
	end

	local frameTotWidth = HGF.activeVars["frameWidth"] + HGF.activeVars["frameDistance"]
	local frameTotHeight = HGF.activeVars["frameHeight"] + HGF.activeVars["frameDistance"]
	local widthOff = -(frameTotWidth * xGrow)
	local heightOff = 0

	while unitTagIterator ~= nil do
		unitFrame = HGF.UI.unitFrames[unitTagIterator.unitTag]
		if unitFrame ~= nil then
			unitFrame.main:ClearAnchors()
			if (nbrFrames % HGF.activeVars["maxPerCol"]) == 0 then
				-- New column
				widthOff = widthOff + (frameTotWidth * xGrow)
				heightOff = 0
			else
				-- New row
				heightOff = heightOff + (frameTotHeight * yGrow)
			end
			unitFrame.main:SetAnchor(anchorPoint, HGF.UI.MainWindow, anchorPoint, widthOff, heightOff)
			nbrFrames = nbrFrames + 1
		end
		unitTagIterator = unitTagIterator.next
	end
end

function HGF.UI.IsAboveCenter(unitTag, y)
	if HGF.UI.unitFrames[unitTag] == nil then
		return end

	local unitFrame = HGF.UI.unitFrames[unitTag].main
	local half = unitFrame:GetHeight() / 2
	return y < (unitFrame:GetTop() + half)
end

function HGF.UI.DoesContain(unitTag, x, y)
	if HGF.UI.unitFrames[unitTag] == nil then
		return end

	local unitFrame = HGF.UI.unitFrames[unitTag].main
	if y < unitFrame:GetBottom() and y > unitFrame:GetTop() and x > unitFrame:GetLeft() and x < unitFrame:GetRight() then
		return true
	else
		return false
	end
end

function HGF.UI.SetUnitLeader(leaderUnitTag)
	if not HGF.activeVars["showLeaderIcon"] then
		return end

	for unitTag, unitFrame in pairs(HGF.UI.unitFrames) do
		if unitTag == leaderUnitTag then
			unitFrame.leader:SetWidth(HGF.UI.leaderWidth)
			unitFrame.leader:SetHidden(false)
		else
			unitFrame.leader:SetWidth(0)
			unitFrame.leader:SetHidden(true)
		end
		HGF.UI.UpdateTextWidth(unitTag)
	end
end

function HGF.UI.UpdateUnitWithinRange(unitTag, inRange)
	if HGF.UI.unitFrames[unitTag] == nil then
		return end

	local newAlpha
	if inRange then
		newAlpha = HGF.activeVars["inRangeAlpha"]
	else
		newAlpha = HGF.activeVars["outOfRangeAlpha"]
	end
	HGF.UI.unitFrames[unitTag].main:SetAlpha(newAlpha)
end

function HGF.UI.UpdateUnitName(unitTag, name, atName)
	if HGF.UI.unitFrames[unitTag] == nil then
		return end

	for i = 1, 4, 1 do
		if HGF.activeVars["textType"][i] == HGF.textName then
			HGF.UI.SetText(unitTag, i, name)
		end
		if HGF.activeVars["textType"][i] == HGF.textAtName then
			HGF.UI.SetText(unitTag, i, atName)
		end
	end
end

function HGF.UI.FormatThousandSeparator(value)
	local formatted = value
	if HGF.activeVars["thousandSeparator"] ~= "" then
		while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1'..HGF.activeVars["thousandSeparator"]..'%2')
			if (k == 0) then
				break
			end
		end
		
	end
	return formatted
end

function HGF.UI.FormatValueToString(value)
	local result, calcVal, prefix

	prefix = nil
	calcVal = value
	if HGF.activeVars["truncateValues"] then
		if value > 1000000000 then
			calcVal = value / 1000000000
			prefix = "G"
		elseif value > 1000000 then
			calcVal = value / 1000000
			prefix = "M"
		elseif value > 1000 then
			calcVal = value / 1000
			prefix = "k"
		end
		if prefix ~= nil then
			result = string.format("%."..HGF.activeVars["truncateDecimals"].."f", calcVal)..prefix
		else
			result = calcVal
		end
	else
		result = HGF.UI.FormatThousandSeparator(value)
	end

	return result
end

function HGF.UI.UpdateUnitHealth(unitTag, currentHp, maxHp, currentShield)
	if HGF.UI.unitFrames[unitTag] == nil then
		return end

	local hpPerc, lostHp, currentHpNice, maxHpNice, lostHpNice, shieldPerc, currentShieldNice

	lostHp = maxHp - currentHp

	if HGF.activeVars["shieldAsHp"] and currentShield > 0 then
		currentHp = currentHp + currentShield
	end

	if maxHp > 0 then
		hpPerc = (currentHp / maxHp) * 100
	else
		hpPerc = 0
	end

	currentHpNice = HGF.UI.FormatValueToString(currentHp)
	maxHpNice = HGF.UI.FormatValueToString(maxHp)
	lostHPNice = "-"..HGF.UI.FormatValueToString(lostHp)
	currentShieldNice = HGF.UI.FormatValueToString(currentShield)

	for i = 1, 4, 1 do
		if HGF.activeVars["textType"][i] == HGF.textHPLeft then
			HGF.UI.SetText(unitTag, i, currentHpNice)
		elseif HGF.activeVars["textType"][i] == HGF.textHPLost then
			HGF.UI.SetText(unitTag, i, lostHpNice)
		elseif HGF.activeVars["textType"][i] == HGF.textHPLeftMax then
			HGF.UI.SetText(unitTag, i, currentHpNice.."/"..maxHpNice)
		elseif HGF.activeVars["textType"][i] == HGF.textHPPerc then
			HGF.UI.SetText(unitTag, i, string.format("%.0f", hpPerc).."%")
		elseif HGF.activeVars["textType"][i] == HGF.textShield then
			HGF.UI.SetText(unitTag, i, currentShieldNice)
		end
	end

	if maxHp <= 0 or currentShield <= 0 then
		shieldPerc = 0
	elseif currentShield >= maxHp then
		shieldPerc = 100
	else
		shieldPerc = (currentShield / maxHp) * 100
	end
	if hpPerc > 100 then
		hpPerc = 100
	end
	HGF.UI.unitFrames[unitTag].hpBar:SetValue(hpPerc)
	HGF.UI.unitFrames[unitTag].shield:SetValue(shieldPerc)
	HGF.UI.unitFrames[unitTag].dead:SetHidden(true)
	HGF.UI.unitFrames[unitTag].offline:SetHidden(true)
end

function HGF.UI.SetOptionalBuffs(unitTag, warhorn, berserk, warhornAndBerserk)
	if HGF.UI.unitFrames[unitTag] == nil then
		return end
		
	local currentColorCode = {HGF.activeVars["healthBarColor"][1],HGF.activeVars["healthBarColor"][2],HGF.activeVars["healthBarColor"][3]}	

	--No switch statements in Lua, reeee		
	if HGF.activeVars["showWarhorn"] and  warhorn >= 1 then
	currentColorCode = {} --need to clear previous values
		currentColorCode[1] = HGF.activeVars["hornBarColor"][1] 
		currentColorCode[2] = HGF.activeVars["hornBarColor"][2]
		currentColorCode[3] = HGF.activeVars["hornBarColor"][3]
	end
		
	if HGF.activeVars["showBerserk"] and  berserk >= 1 then
		currentColorCode = {} --need to clear previous values
		currentColorCode[1] = HGF.activeVars["berserkBarColor"][1] 
		currentColorCode[2] = HGF.activeVars["berserkBarColor"][2]
		currentColorCode[3] = HGF.activeVars["berserkBarColor"][3]
	end	
	
	if HGF.activeVars["showWarhornAndBerserk"] and warhornAndBerserk >= 1 then
		currentColorCode = {} --need to clear previous values
		currentColorCode[1] = HGF.activeVars["hornAndBerserkBarColor"][1] 
		currentColorCode[2] = HGF.activeVars["hornAndBerserkBarColor"][2]
		currentColorCode[3] = HGF.activeVars["hornAndBerserkBarColor"][3]	
	end
	
	HGF.UI.unitFrames[unitTag].hpBar:SetColor(currentColorCode[1],currentColorCode[2],currentColorCode[3])
end



function HGF.UI.SetUnitStealth(unitTag, stealthState)
	if not HGF.activeVars["showStealthIndicator"] or
			HGF.UI.unitFrames[unitTag] == nil then
		return end

	local stealthed = true
	local newWidth = 0

	stealthed = (stealthState ~= STEALTH_STATE_NONE)
	if stealthed then
		newWidth = HGF.UI.stealthWidth
	end
	HGF.UI.unitFrames[unitTag].stealth:SetWidth(newWidth)
	HGF.UI.unitFrames[unitTag].stealth:SetHidden(not stealthed)
	HGF.UI.UpdateTextWidth(unitTag)
end

function HGF.UI.SetUnitDead(unitTag)
	if HGF.UI.unitFrames[unitTag] == nil then
		return end

	for i = 1, 4, 1 do
		if HGF.activeVars["textType"][i] ~= HGF.textName or HGF.activeVars["textType"][i] ~= HGF.textAtName then
			HGF.UI.SetText(unitTag, i, "")
		end		
	end
	HGF.UI.SetUnitStealth(unitTag, false)
	HGF.UI.unitFrames[unitTag].hpBar:SetValue(0)
	HGF.UI.unitFrames[unitTag].shield:SetValue(0)
	HGF.UI.unitFrames[unitTag].dead:SetHidden(false)
	HGF.UI.unitFrames[unitTag].offline:SetHidden(true)
end

function HGF.UI.SetUnitOffline(unitTag)
	if HGF.UI.unitFrames[unitTag] == nil then
		return end

	for i = 1, 4, 1 do
		if HGF.activeVars["textType"][i] ~= HGF.textName or HGF.activeVars["textType"][i] ~= HGF.textAtName then
			HGF.UI.SetText(unitTag, i, "")
		end
	end
	HGF.UI.SetUnitStealth(unitTag, false)
	HGF.UI.unitFrames[unitTag].hpBar:SetValue(0)
	HGF.UI.unitFrames[unitTag].shield:SetValue(0)
	HGF.UI.unitFrames[unitTag].dead:SetHidden(true)
	HGF.UI.unitFrames[unitTag].offline:SetHidden(false)
end

function HGF.UI.EnableUnitFrame(unitTag)
	if HGF.UI.unitFrames[unitTag] == nil then
		return end

	HGF.UI.unitFrames[unitTag].main:SetHidden(false)
end

function HGF.UI.DisableUnitFrame(unitTag)
	if HGF.UI.unitFrames[unitTag] == nil then
		return end

	HGF.UI.unitFrames[unitTag].main:SetHidden(true)
end

function HGF.UI.GetAnchorPoint()
	local anchor = TOPLEFT
	if HGF.activeVars["growDirV"] == "down" and HGF.activeVars["growDirH"] == "right" then
		anchor = TOPLEFT
	elseif HGF.activeVars["growDirV"] == "up" and HGF.activeVars["growDirH"] == "right" then
		anchor = BOTTOMLEFT
	elseif HGF.activeVars["growDirV"] == "down" and HGF.activeVars["growDirH"] == "left" then
		anchor = TOPRIGHT
	elseif HGF.activeVars["growDirV"] == "up" and HGF.activeVars["growDirH"] == "left" then
		anchor = BOTTOMRIGHT
	else
		d("HGF.UI.AnchorMainWindow: Could not determine anchor point!")
	end
	return anchor
end

function HGF.UI.HideFrames(hide)
	HGF.UI.MainWindow:SetHidden(hide)
end

function HGF.UI.HideAnchor(hide)
	local width, height
	if hide then
		width = 0
		height = 0
	else
		width = ((HGF.activeVars["frameWidth"] + HGF.activeVars["frameDistance"]) * (24 / HGF.activeVars["maxPerCol"])) - HGF.activeVars["frameDistance"]
		height = ((HGF.activeVars["frameHeight"] + HGF.activeVars["frameDistance"]) * HGF.activeVars["maxPerCol"]) - HGF.activeVars["frameDistance"]
	end
	HGF.UI.MainAnchorBG:SetDimensions(width, height)
	HGF.UI.MainAnchorBG:SetMouseEnabled(not hide)
	HGF.UI.MainAnchor:SetHidden(hide)
end

function HGF.UI.SetMainAnchorPos(x, y)
	HGF.UI.MainAnchor:ClearAnchors()
	HGF.UI.MainAnchor:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
	HGF.activeVars["MW_Pos"][1] = x
	HGF.activeVars["MW_Pos"][2] = y
end

function HGF.UI.SetMainAnchorPosToUnit(unitTag)
	if HGF.UI.unitFrames[unitTag] == nil then
		return end

	local x, y
	if HGF.activeVars["growDirH"] == "right" then
		x = HGF.UI.unitFrames[unitTag].main:GetLeft()
	else
		x = HGF.UI.unitFrames[unitTag].main:GetRight()
	end
	if HGF.activeVars["growDirV"] == "down" then
		y = HGF.UI.unitFrames[unitTag].main:GetTop()
	else
		y = HGF.UI.unitFrames[unitTag].main:GetBottom()
	end
	HGF.UI.SetMainAnchorPos(x, y)
end

function HGF.UI.Initialize()
	local anchor = HGF.UI.GetAnchorPoint()

	HGF.UI.MainAnchor = WINDOW_MANAGER:CreateTopLevelWindow("HGF_MainAnchor")
	HGF.UI.MainAnchor:SetAllowBringToTop(false)
	HGF.UI.MainAnchor:SetDimensions(0, 0)
	HGF.UI.MainAnchor:SetHidden(true)
	HGF.UI.SetMainAnchorPos(HGF.activeVars["MW_Pos"][1], HGF.activeVars["MW_Pos"][2])

	HGF.UI.MainAnchorBG = WINDOW_MANAGER:CreateControl("HGF_MainAnchor_BG", HGF.UI.MainAnchor, CT_BACKDROP)
	HGF.UI.MainAnchorBG:SetAnchor(anchor, HGF.UI.MainAnchor, anchor, 0, 0)
	HGF.UI.MainAnchorBG:SetDimensions(0, 0)
	HGF.UI.MainAnchorBG:SetCenterColor(0.3, 0.3, 0.3, 0.8)
	HGF.UI.MainAnchorBG:SetEdgeColor(1, 1, 1, 0)
	HGF.UI.MainAnchorBG:SetMovable(true)
	HGF.UI.MainAnchorBG:SetMouseEnabled(false)
	HGF.UI.MainAnchorBG:SetHandler("OnMouseUp", function(self)
			HGF.UI.SetMainAnchorPos(self:GetLeft(), self:GetTop())
		 end)

	HGF.UI.MainAnchorText = WINDOW_MANAGER:CreateControl("HGF_MainAnchor_Text", HGF.UI.MainAnchor, CT_LABEL)
	HGF.UI.MainAnchorText:SetAnchorFill(HGF.UI.MainAnchorBG)
	HGF.UI.MainAnchorText:SetColor(0.9, 0.9, 0.9, 1)
	HGF.UI.MainAnchorText:SetFont(HGF.activeVars["font"])
	HGF.UI.MainAnchorText:SetText("Approximation of full group frame")
	HGF.UI.MainAnchorText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	HGF.UI.MainAnchorText:SetVerticalAlignment(TEXT_ALIGN_CENTER)

	HGF.UI.MainWindow = WINDOW_MANAGER:CreateTopLevelWindow("HGF_MainWindow")
	HGF.UI.MainWindow:SetDimensions(0, 0)
	HGF.UI.MainWindow:SetHidden(false)
	HGF.UI.MainWindow:SetAnchor(TOPLEFT, HGF.UI.MainAnchor, TOPLEFT, 0, 0)

	-- Disable default group frames
	ZO_UnitFramesGroups:SetHidden(true)
end