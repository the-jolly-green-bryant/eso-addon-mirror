local g_isInit = false
local g_currentBossCount = 0

local function GetHPString(_powerValue, _powerMax)
	local unitPercent = AUI.Math.Round((_powerValue / _powerMax) * 100)
	
	local hpString = ""
	local cValue = AUI.Math.Round(_powerValue)
	local maxValue = AUI.Math.Round(_powerMax)
	
	if AUI.Settings.UnitFrames.boss_game_default_frame_use_thousand_seperator then
		cValue = AUI.String.ToFormatedNumber(_powerValue)
		maxValue = AUI.String.ToFormatedNumber(_powerMax)
	end
	
	if _powerValue > 1 then
		hpString = cValue .. " \\ " .. maxValue .. " (" ..  unitPercent .. "%)"
	end
	
	return hpString	
end

function AUI.UnitFrames.Boss.UpdateUI()
	if not g_isInit then
		return
	end

	local isPreviewShowed = AUI.UnitFrames.IsPreviewShow()
		
	if g_currentBossCount >= 2 or isPreviewShowed then
		local frameCount = 0
	
		local maxRowCount = 4
		local blockCount = 1
							
		local currentTop = 0
		local currentBlockTop = 0
		local currentBlockLeft = 0
		local currentLeft = 0

		local frameHeight = 0
		local frameWidth = 0
		local rowCount = 4		
	
		local currentTemplate = AUI.UnitFrames.GetActiveBossTemplateData()
	
		if not currentTemplate then
			return
		end
	
		local frames = currentTemplate.frameData[AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].control.frames
		local shieldFrames = currentTemplate.frameData[AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].control.frames
		
		for i = 1, MAX_BOSSES, 1 do
			local unitTag = "boss" .. i	
			local bossFrame = frames[unitTag]
			local bossShieldFrame = shieldFrames[unitTag]		
		
			if bossFrame and bossShieldFrame then	
				if DoesUnitExist(unitTag) and not IsUnitDead(unitTag) or isPreviewShowed then	
					rowCount = bossFrame.settings.row_count or MAX_BOSSES
					frameHeight = bossFrame:GetHeight()
					frameWidth = bossFrame:GetWidth()						
							
					if bossFrame.settings.row_distance then
						frameHeight = frameHeight + bossFrame.settings.row_distance 
					end
															
					if  bossFrame.settings.column_distance then
						frameWidth = frameWidth + bossFrame.settings.column_distance 
					end										
																											
					if frameCount > 1 and frameCount % (rowCount * 3) == 0 then
						if blockCount % 2 == 0 then
							currentBlockTop = 0
							currentTop = 0
							currentLeft = (currentLeft + frameWidth) + 20
							currentBlockLeft = currentLeft
						else
							currentLeft = currentBlockLeft
							currentTop = (currentTop + frameHeight) + 8
							currentBlockTop = currentTop
						end
											
						blockCount = blockCount + 1
					elseif frameCount % rowCount == 0 then
						if frameCount > 1 then
							currentTop = currentBlockTop
							currentLeft = currentLeft + frameWidth
						end
					else
						currentTop = currentTop + frameHeight
					end
					bossFrame:ClearAnchors()				
					bossFrame:SetAnchor(TOPLEFT, _parent, TOPLEFT, currentLeft, currentTop)																					
					
					frameCount = frameCount + 1
				end
			end			
		end
		
		if frameCount > 0 then
			AUI_Attributes_Window_Boss:SetHidden(false)
		else
			AUI_Attributes_Window_Boss:SetHidden(true)
		end
		
		AUI.UnitFrames.Boss.UpdateText()
	else
		AUI_Attributes_Window_Boss:SetHidden(true)	
	end
end

function AUI.UnitFrames.Boss.UpdateText(_powerValue, _powerMax, _powerEffectiveMax)
	local totalValue = 0
	local totalMaxValue = 0

	for i = 1, MAX_BOSSES, 1 do
		local unitTag = "boss" .. i
			
		if DoesUnitExist(unitTag) and not IsUnitDead(unitTag) then
			if not _powerValue and not _powerMax then
				_powerValue, _powerMax, _powerEffectiveMax = GetUnitPower(unitTag, POWERTYPE_HEALTH)						
			end											
				
			totalValue = totalValue + _powerValue
			totalMaxValue = totalMaxValue + _powerMax
		end
	end		
	
	if AUI.UnitFrames.IsPreviewShow() then
		totalValue = DEFAULT_PREVIEW_HP
		totalMaxValue = DEFAULT_PREVIEW_HP
	end		
	
	local hpString = GetHPString(totalValue, totalMaxValue)
	AUI_BossBarOverlay_Text:SetText(hpString)
end

function AUI.UnitFrames.Boss.ShowPreview()
	if not g_isInit then
		return
	end

	ZO_BossBar:SetHidden(false)	
	ZO_BossBar:SetAlpha(1)
	ZO_Compass:SetHidden(true)
	ZO_CompassFrame:SetHidden(false)
	
	AUI.UnitFrames.Boss.OnChanged()
end

function AUI.UnitFrames.Boss.HidePreview()
	if not g_isInit then
		return
	end

	ZO_BossBar:SetHidden(true)
	ZO_BossBar:SetAlpha(0)
	ZO_Compass:SetHidden(false)
	ZO_CompassFrame:SetHidden(true)	
end

function AUI.UnitFrames.Boss.OnChanged()
	if not g_isInit then
		return
	end	
	
	local totalValue = 0
	local totalMaxValue = 0	

	if AUI.UnitFrames.IsPreviewShow() then
		totalValue = DEFAULT_PREVIEW_HP
		totalMaxValue = DEFAULT_PREVIEW_HP
		g_currentBossCount = 6
	else	
		g_currentBossCount = 0
		for i = 1, MAX_BOSSES, 1 do
			local unitTag = "boss" .. i
			if DoesUnitExist(unitTag) then
				if not _powerValue and not _powerMax then
					_powerValue, _powerMax, _powerEffectiveMax = GetUnitPower(unitTag, POWERTYPE_HEALTH)
				end			
			
				totalValue = totalValue + _powerValue
				totalMaxValue = totalMaxValue + _powerMax		
			
				g_currentBossCount = g_currentBossCount + 1
				AUI.UnitFrames.Update(unitTag)
			end
		end	
	end
	
	local hpString = GetHPString(totalValue, totalMaxValue)	
	AUI_BossBarOverlay_Text:SetText(hpString)	
	
	AUI.UnitFrames.Boss.UpdateUI()
end

function AUI.UnitFrames.Boss.Load()	
	if g_isInit then		
		return
	end
	
	AUI.UnitFrames.Boss.OnChanged()
	g_isInit = true	
end