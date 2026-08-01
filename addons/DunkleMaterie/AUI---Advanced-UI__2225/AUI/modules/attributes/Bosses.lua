local LMP = LibStub("LibMediaProvider-1.0")

local isLoaded = false
local currentBossCount = 0

local function GetHPString(_powerValue, _powerMax)
	local unitPercent = AUI.Math.Round((_powerValue / _powerMax) * 100)
	
	local hpString = ""
	local cValue = AUI.Math.Round(_powerValue)
	local maxValue = AUI.Math.Round(_powerMax)
	
	if AUI.Settings.Attributes.boss_use_thousand_seperator then
		cValue = AUI.String.ToFormatedNumber(_powerValue)
		maxValue = AUI.String.ToFormatedNumber(_powerMax)
	end
	
	if _powerValue > 1 then
		hpString = cValue .. " \\ " .. maxValue .. " (" ..  unitPercent .. "%)"
	end
	
	return hpString	
end

function AUI.Attributes.Bossbar.UpdateUI()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Bossbar.UpdateUI")
	end
	--/DebugMessage--

	local isPreviewShowed = AUI.Attributes.IsPreviewShow()
		
	if currentBossCount >= 2 or isPreviewShowed then
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
	
		local currentTemplate = AUI.Attributes.GetCurrentTemplateData()
	
		if not currentTemplate then
			return
		end
	
		local frames = currentTemplate.attributeData[AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].control.frames
		local shieldFrames = currentTemplate.attributeData[AUI_ATTRIBUTE_TYPE_BOSS_SHIELD].control.frames
		
		for i = 1, MAX_BOSSES, 1 do
			local unitTag = "boss" .. i	
			local bossFrame = frames[unitTag]
			local bossShieldFrame = shieldFrames[unitTag]		
		
			if bossFrame and bossShieldFrame then	
				if DoesUnitExist(unitTag) and not IsUnitDead(unitTag) or isPreviewShowed then	
					rowCount = bossFrame.settings.rowCount or MAX_BOSSES
					frameHeight = bossFrame:GetHeight()
					frameWidth = bossFrame:GetWidth()						
							
					if bossFrame.settings.rowDistance then
						frameHeight = frameHeight + bossFrame.settings.rowDistance 
					end
															
					if  bossFrame.settings.columnDistance then
						frameWidth = frameWidth + bossFrame.settings.columnDistance 
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
		
		AUI.Attributes.Bossbar.UpdateText()
	else
		AUI_Attributes_Window_Boss:SetHidden(true)	
	end
end

function AUI.Attributes.Bossbar.UpdateText(_powerValue, _powerMax, _powerEffectiveMax)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Bossbar.UpdateText")
	end
	--/DebugMessage--

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
	
	if AUI.Attributes.IsPreviewShow() then
		totalValue = DEFAULT_PREVIEW_HP
		totalMaxValue = DEFAULT_PREVIEW_HP
	end		
	
	local hpString = GetHPString(totalValue, totalMaxValue)
	AUI_BossBarOverlay_Text:SetText(hpString)
end

function AUI.Attributes.Bossbar.ShowPreview()
	if not isLoaded then
		return
	end

	ZO_BossBar:SetHidden(false)	
	ZO_BossBar:SetAlpha(1)
	ZO_Compass:SetHidden(true)
	ZO_CompassFrame:SetHidden(false)
	
	AUI.Attributes.Bossbar.OnChanged()
end

function AUI.Attributes.Bossbar.HidePreview()
	if not isLoaded then
		return
	end

	ZO_BossBar:SetHidden(true)
	ZO_BossBar:SetAlpha(0)
	ZO_Compass:SetHidden(false)
	ZO_CompassFrame:SetHidden(true)	
end

function AUI.Attributes.Bossbar.OnChanged()
	if not isLoaded then
		return
	end	
	
	local totalValue = 0
	local totalMaxValue = 0	

	if AUI.Attributes.IsPreviewShow() then
		totalValue = DEFAULT_PREVIEW_HP
		totalMaxValue = DEFAULT_PREVIEW_HP
		currentBossCount = 6
	else	
		currentBossCount = 0
		for i = 1, MAX_BOSSES, 1 do
			local unitTag = "boss" .. i
			if DoesUnitExist(unitTag) then
				if not _powerValue and not _powerMax then
					_powerValue, _powerMax, _powerEffectiveMax = GetUnitPower(unitTag, POWERTYPE_HEALTH)
				end			
			
				totalValue = totalValue + _powerValue
				totalMaxValue = totalMaxValue + _powerMax		
			
				currentBossCount = currentBossCount + 1
				AUI.Attributes.Update(unitTag)
			end
		end	
	end
	
	local hpString = GetHPString(totalValue, totalMaxValue)	
	AUI_BossBarOverlay_Text:SetText(hpString)	
	
	AUI.Attributes.Bossbar.UpdateUI()
end

function AUI.Attributes.Bossbar.Load()	
	if not isLoaded then		
		AUI.Attributes.Bossbar.OnChanged()
	end
	
	isLoaded = true	
end