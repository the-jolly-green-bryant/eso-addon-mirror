--[[----------------------------------------------------------
    CurvyHud 
    ----------------------------------------------------------
	Localization 	: 	/Main/Builder.lua 
    Original Author	:	Niocwy
	Update Author 	:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

local L = CurvyHud:GetLoc()

-- round a number to closest integer
local function round(num) 

	if (num >= 0) then 
		return math.floor(num + 0.5) 
	else 
		return math.ceil(num - 0.5) 
	end
end

-- deepcopy a table
local function deepcopy(orig)

    local orig_type = type(orig)
    local copy
	
    if orig_type == "table" then
        copy = {}
        for orig_key,  orig_value in next,  orig,  nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy,  deepcopy(getmetatable(orig)))
    else -- number,  string,  boolean,  etc
        copy = orig
    end
    return copy
end

-- Format attribute value with the given text format
function CurvyHud.FormatTextValues(textFormat, currentValue, maxValue, percentValue)

	local newCurrentValue
	local newMaxValue = maxValue
	if (CurvyHud.config.localizationDecimal) then
		newCurrentValue =	zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(currentValue))
		if (newMaxValue ~= nil) then
			newMaxValue 	=	zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(maxValue))
		end
	else
		newMaxValue 	= maxValue
		newCurrentValue = currentValue
	end
	local text = string.gsub(textFormat, "{val}", tostring(newCurrentValue))
	text = string.gsub(text, "{per}", tostring(percentValue))
	text = string.gsub(text, "{max}", tostring(newMaxValue))
	return text
end

function CurvyHud:BuildVisualizers()

	ZO_CreateStringId("SI_BINDING_NAME_CURVYHUD_FRAMES_RELOAD", L.Reload..L.CurvyHud)
	ZO_CreateStringId("SI_BINDING_NAME_CURVYHUD_CHRONO_RELOAD", L.Chrono)
	local topControl 	= self.topControl or  WINDOW_MANAGER:CreateTopLevelWindow("CURVY_TopControl") 
	self.topControl 	= topControl
	topControl:SetDimensions(GuiRoot:GetWidth(), GuiRoot:GetHeight())
	topControl:SetAnchor(TOPLEFT)

	CurvyHud:BuildBarContainers()
	CurvyHud:BuildTargetNameplate()
	CurvyHud:BuildInteractionPrompt()
	CurvyHud:BuildPlayerinteractionPrompt()
	CurvyHud:ToggleDefaultPlayerFrameHide()
	CurvyHud:ToggleDefaultTargetFrame()
	CurvyHud:ToggleCombatCompass()
	CurvyHud:ToggleReticleOption()
	CurvyHud:ZoCombatTips()
	CurvyHud:SlashCommands()
	CurvyHud:BuildLowAttributes()
	CurvyHud:BuildCombatTips()
	CurvyHud:BuildTaunt()
	CurvyHud:BuildReticle()
	CurvyHud:BuildClepsydre()
end

-- Build the bar containers
function CurvyHud:BuildBarContainers()

	local textureCfg		= CurvyHud.textures[CurvyHud.config.textureConfig]
	-- Creating and positioning the left and right containers 
	local containerLeft 	= self.barContainerLeft or WINDOW_MANAGER:CreateControl("CURVY_BarContainer_Left", self.topControl, CT_CONTROL)
	self.barContainerLeft 	= containerLeft
	CurvyHud.config.barContainerLeft.anchor[2] = GuiRoot
	containerLeft:ClearAnchors()
	containerLeft:SetAnchor(unpack(CurvyHud.config.barContainerLeft.anchor))
	containerLeft.count		= 0
	containerLeft.bars 		= {}
	
	local containerRight 	= self.barContainerRight or WINDOW_MANAGER:CreateControl("CURVY_BarContainer_Right", self.topControl, CT_CONTROL) 
	self.barContainerRight 	= containerRight
	CurvyHud.config.barContainerRight.anchor[2] = GuiRoot
	containerRight:ClearAnchors()
	containerRight:SetAnchor(unpack(CurvyHud.config.barContainerRight.anchor))
	containerRight.count 	= 0
	containerRight.bars 	= {}
	-- Creating the attribute bars
	for i,  barName in ipairs (CurvyHud.barList) do
		CurvyHud:BuildBar(barName)
		CurvyHud:BuildTextValues(barName)
		if(CurvyHud.config[barName].position == "left") then
			containerLeft.count = containerLeft.count + 1
		else
			containerRight.count = containerRight.count + 1
		end
	end

	local barThickness = (textureCfg.barThickness/textureCfg.barWidth) * CurvyHud.config.barWidth
	containerLeft :SetDimensions(CurvyHud.config.barWidth + (CurvyHud.config.barSpacing + barThickness) * 2,  CurvyHud.config.barHeight)
	containerRight:SetDimensions(CurvyHud.config.barWidth + (CurvyHud.config.barSpacing + barThickness) * 2,  CurvyHud.config.barHeight)
	-- adding containers to movable frames
	self.movableFrames.barContainerLeft = containerLeft
	self.movableFrames.barContainerLeft.anchorConfig = CurvyHud.config.barContainerLeft.anchor
	self.movableFrames.barContainerRight = containerRight
	self.movableFrames.barContainerRight.anchorConfig = CurvyHud.config.barContainerRight.anchor
end

-- Build the given bar
function CurvyHud:BuildBar(barName)
	-- useful locals
	local cfg 			= self.config
	local textureCfg 	= self.textures[cfg.textureConfig]
	local barCfg		= self.config[barName]
	local visualsCfg 	= (barName == "targetBar" and cfg.targetVisuals or cfg.visuals)
	--
	-- Pre-calculating positioning values
	--
	-- Setting the container, texture file and anchor depending on the position (left or right)
	local textureFile  		= textureCfg.fileRight
	local container			= self.barContainerRight
	local containerConfig 	= cfg.barContainerRight
	local anchor 			= LEFT
	local x 				= 1
	
	if (barCfg.position == "left") then
		x					= -1
		textureFile 		= textureCfg.fileLeft
		container 			= self.barContainerLeft
		containerConfig 	= cfg.barContainerLeft
		anchor 				= RIGHT
	end
	-- setting "step size" for stairway style 
	local stepSize = (containerConfig.stepOn and textureCfg.stepSize or 0)
	-- setting inGame/texture aspect ratio 
	local ratioH = cfg.barHeight / textureCfg.barHeight -- vertical ratio,  H stands for Height
	local ratioW = cfg.barWidth / textureCfg.barWidth	  -- horizontal ratio,  W stands for Width	
	-- Calculating horizontal offset,  which effectively sets the position in the container
	local barThickness = round(textureCfg.barThickness * ratioW)
	local xOffset = (barThickness+cfg.barSpacing) * barCfg.index * x
	--
	-- Creating the main bar frame,  containing all others
	--	
	local bar 			= self.bars[barName] or self[barName] or WINDOW_MANAGER:CreateControl("CURVY_"..barName, container, CT_CONTROL)
	self.bars[barName] 	= bar
	container.bars[barName] = bar
	bar:ClearAnchors()
	bar:SetAnchor(anchor, container, anchor, xOffset, 0)
	bar:SetDimensions(cfg.barWidth, cfg.barHeight)
	-- saving config in the bar for easy access later
	bar.config = barCfg
	--
	-- Creating Background
	--	
	local backgroundStepSize 		= barCfg.index * stepSize
	local backgroundStepSizeT		= 0
	local backgroundHeight 			=  cfg.barHeight - (backgroundStepSize+backgroundStepSizeT) * ratioH
	local backgroundYOffset 		= -backgroundStepSize * ratioH
	local backgroundTextureCoords 	= deepcopy(textureCfg.coords["background"])
	backgroundTextureCoords[3] 		= backgroundTextureCoords[3] + backgroundStepSizeT/textureCfg.textureHeight
	backgroundTextureCoords[4] 		= backgroundTextureCoords[4] - backgroundStepSize /textureCfg.textureHeight
	
	local background 	= 	bar.background or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
	bar.background 		= background
	background:ClearAnchors()
	background:SetColor(unpack(barCfg.backgroundColor))
	background:SetTexture(textureFile)
	background:SetTextureCoords(unpack(backgroundTextureCoords))
	background:SetDimensions(cfg.barWidth, backgroundHeight)
	background:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, backgroundYOffset)
	--
	-- Creating Left and right border 
	--	
	local borderStepSize 		= backgroundStepSize 	+ textureCfg.borderMargin + textureCfg.borderSize
	local borderStepSizeT 		= backgroundStepSizeT 	+ textureCfg.borderMargin + textureCfg.borderSize
	local borderHeight 			= cfg.barHeight - (borderStepSize+borderStepSizeT) * ratioH
	local borderYOffset 		= - borderStepSize * ratioH
	local borderTextureCoords 	= deepcopy(textureCfg.coords["border"])
	borderTextureCoords[3] 		= borderTextureCoords[3] + borderStepSizeT / textureCfg.barHeight
	borderTextureCoords[4] 		= borderTextureCoords[4] - borderStepSize / textureCfg.textureHeight

	local border 	= bar.border  or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)	
	bar.border 		= border
	border:ClearAnchors()
	border:SetTexture(textureFile)
	border:SetTextureCoords(unpack(borderTextureCoords))
	border:SetDimensions(cfg.barWidth, borderHeight)
	border:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, borderYOffset)
	--
	-- Creating Filler
	--	
	local fillerStepSize 	= borderStepSize + textureCfg.borderMargin
	local fillerStepSizeT 	= borderStepSizeT + textureCfg.borderMargin
	local fillerHeight		= cfg.barHeight - (fillerStepSize+fillerStepSizeT) * ratioH
	local fillerStepYOffset = -fillerStepSize * ratioH
	local fillerTCoords		= deepcopy(textureCfg.coords["filler"])
	fillerTCoords[3]		= fillerTCoords[3] + fillerStepSizeT / textureCfg.textureHeight
	fillerTCoords[4]		= fillerTCoords[4] - fillerStepSize / textureCfg.textureHeight
	
	local filler 	= bar.filler or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
	bar.filler 		= filler
	bar.filler:ClearAnchors()	
	filler:SetColor(unpack(barCfg.colorMax))
	filler:SetTexture(textureFile)
	filler:SetTextureCoords(unpack(fillerTCoords))
	filler:SetDimensions(cfg.barWidth, fillerHeight)
	filler:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, fillerStepYOffset)
	-- saving filler infos for update of the bar later
	filler.baseHeight = fillerHeight
	filler.baseTextureCoords = deepcopy(fillerTCoords)

	-- obviously, only in healthBar and targetBar
	if(barName == "healthBar" or barName == "targetBar") then
		--
		-- Creating shield bar
		--	
		local shield 	= bar.shield or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.shield		= shield
		bar.shield:ClearAnchors()
		
		shield:SetColor(unpack(visualsCfg.shield.color))
		shield:SetTexture(textureFile)
		shield:SetTextureCoords(unpack(fillerTCoords))
		shield:SetDimensions(cfg.barWidth, 0)
		shield:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, fillerStepSizeT * ratioH)
		shield:SetHidden(false)
		-- saving shield bar infos for update later
		shield.baseAnchor = {TOPLEFT, bar, TOPLEFT, 0, fillerStepSizeT * ratioH}
		-- MAJORS EFFECTS
		-- Creating Major Physical Resistance Increase
		local majPhysResistInc 	= bar.majPhysResistInc or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.majPhysResistInc 	= majPhysResistInc
		bar.majPhysResistInc:ClearAnchors()
	
		local majPhysResistIncTCoords =  deepcopy(textureCfg.coords["phys_major_Inc"])
		majPhysResistInc:SetColor(unpack(cfg.effects.physResistIncColor))
		majPhysResistInc:SetTexture(textureFile)
		majPhysResistInc:SetTextureCoords(unpack(majPhysResistIncTCoords))
		majPhysResistInc:SetDimensions(cfg.barWidth, cfg.barHeight)
		majPhysResistInc:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		majPhysResistInc:SetHidden(true)
		majPhysResistInc.baseTextureCoords = majPhysResistIncTCoords
		-- Creating Major Physical Resistance Decrease
		local majPhysResistDec	= bar.majPhysResistDec or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.majPhysResistDec 	= majPhysResistDec
		bar.majPhysResistDec:ClearAnchors()
	
		local majPhysResistDecTCoords =  deepcopy(textureCfg.coords["phys_major_Dec"])
		majPhysResistDec:SetColor(unpack(cfg.effects.physResistDecColor))
		majPhysResistDec:SetTexture(textureFile)
		majPhysResistDec:SetTextureCoords(unpack(majPhysResistDecTCoords))
		majPhysResistDec:SetDimensions(cfg.barWidth, cfg.barHeight)
		majPhysResistDec:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		majPhysResistDec:SetHidden(true)
		majPhysResistDec.baseTextureCoords = majPhysResistDecTCoords
		-- Creating Major Spell Resist Increase
		local majSpellResistInc	= bar.majSpellResistInc or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.majSpellResistInc 	= majSpellResistInc
		bar.majSpellResistInc:ClearAnchors()
	
		local majSpellResistIncTCoords =  deepcopy(textureCfg.coords["spell_major_Inc"])
		majSpellResistInc:SetColor(unpack(cfg.effects.spellResistIncColor))
		majSpellResistInc:SetTexture(textureFile)
		majSpellResistInc:SetTextureCoords(unpack(majSpellResistIncTCoords))
		majSpellResistInc:SetDimensions(cfg.barWidth, cfg.barHeight)
		majSpellResistInc:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		majSpellResistInc:SetHidden(true)
		majSpellResistInc.baseTextureCoords = majSpellResistIncTCoords
		-- Creating Major Spell Resist Decrease
		local majSpellResistDec	= bar.majSpellResistDec or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.majSpellResistDec 	= majSpellResistDec
		bar.majSpellResistDec:ClearAnchors()
	
		local majSpellResistDecTCoords =  deepcopy(textureCfg.coords["spell_major_Dec"])
		majSpellResistDec:SetColor(unpack(cfg.effects.spellResistDecColor))
		majSpellResistDec:SetTexture(textureFile)
		majSpellResistDec:SetTextureCoords(unpack(majSpellResistDecTCoords))
		majSpellResistDec:SetDimensions(cfg.barWidth, cfg.barHeight)
		majSpellResistDec:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		majSpellResistDec:SetHidden(true)
		majSpellResistDec.baseTextureCoords = majSpellResistDecTCoords
		
		-- MINORS EFFETCS
		-- Creating Minor Physical Resistance Increase
		local minPhysResistInc 	= bar.minPhysResistInc or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.minPhysResistInc 	= minPhysResistInc
		bar.minPhysResistInc:ClearAnchors()
	
		local minPhysResistIncTCoords =  deepcopy(textureCfg.coords["phys_minor_Inc"])
		minPhysResistInc:SetColor(unpack(cfg.effects.physResistIncColor))
		minPhysResistInc:SetTexture(textureFile)
		minPhysResistInc:SetTextureCoords(unpack(minPhysResistIncTCoords))
		minPhysResistInc:SetDimensions(cfg.barWidth, cfg.barHeight)
		minPhysResistInc:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		minPhysResistInc:SetHidden(true)
		minPhysResistInc.baseTextureCoords = minPhysResistIncTCoords
		-- Creating Minor Physical Resistance Decrease
		local minPhysResistDec	= bar.minPhysResistDec or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.minPhysResistDec 	= minPhysResistDec
		bar.minPhysResistDec:ClearAnchors()
	
		local minPhysResistDecTCoords =  deepcopy(textureCfg.coords["phys_minor_Dec"])
		minPhysResistDec:SetColor(unpack(cfg.effects.physResistDecColor))
		minPhysResistDec:SetTexture(textureFile)
		minPhysResistDec:SetTextureCoords(unpack(minPhysResistDecTCoords))
		minPhysResistDec:SetDimensions(cfg.barWidth, cfg.barHeight)
		minPhysResistDec:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		minPhysResistDec:SetHidden(true)
		minPhysResistDec.baseTextureCoords = minPhysResistDecTCoords
		-- Creating Minor Spell Resist Increase
		local minSpellResistInc	= bar.minSpellResistInc or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.minSpellResistInc 	= minSpellResistInc
		bar.minSpellResistInc:ClearAnchors()
	
		local minSpellResistIncTCoords =  deepcopy(textureCfg.coords["spell_minor_Inc"])
		minSpellResistInc:SetColor(unpack(cfg.effects.spellResistIncColor))
		minSpellResistInc:SetTexture(textureFile)
		minSpellResistInc:SetTextureCoords(unpack(minSpellResistIncTCoords))
		minSpellResistInc:SetDimensions(cfg.barWidth, cfg.barHeight)
		minSpellResistInc:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		minSpellResistInc:SetHidden(true)
		minSpellResistInc.baseTextureCoords = minSpellResistIncTCoords
		-- Creating Minor Spell Resist Decrease
		local minSpellResistDec	= bar.minSpellResistDec or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.minSpellResistDec 	= minSpellResistDec
		bar.minSpellResistDec:ClearAnchors()
	
		local minSpellResistDecTCoords =  deepcopy(textureCfg.coords["spell_minor_Dec"])
		minSpellResistDec:SetColor(unpack(cfg.effects.spellResistDecColor))
		minSpellResistDec:SetTexture(textureFile)
		minSpellResistDec:SetTextureCoords(unpack(minSpellResistDecTCoords))
		minSpellResistDec:SetDimensions(cfg.barWidth, cfg.barHeight)
		minSpellResistDec:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		minSpellResistDec:SetHidden(true)
		minSpellResistDec.baseTextureCoords = minSpellResistDecTCoords
		-- DUALITY
		-- Creating Major Physical Resistance Duality
		local majPhysResistDual 	= bar.majPhysResistDual or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.majPhysResistDual 	= majPhysResistDual
		bar.majPhysResistDual:ClearAnchors()
	
		local majPhysResistDualTCoords =  deepcopy(textureCfg.coords["phys_major_Dual"])
		majPhysResistDual:SetColor(unpack(cfg.effects.physResistDualColor))
		majPhysResistDual:SetTexture(textureFile)
		majPhysResistDual:SetTextureCoords(unpack(majPhysResistDualTCoords))
		majPhysResistDual:SetDimensions(cfg.barWidth, cfg.barHeight)
		majPhysResistDual:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		majPhysResistDual:SetHidden(true)
		majPhysResistDual.baseTextureCoords = majPhysResistDualTCoords
		-- Creating Minor Physical Resistance Duality
		local minPhysResistDual	= bar.minPhysResistDual or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.minPhysResistDual 	= minPhysResistDual
		bar.minPhysResistDual:ClearAnchors()
	
		local minPhysResistDualTCoords =  deepcopy(textureCfg.coords["phys_minor_Dual"])
		minPhysResistDual:SetColor(unpack(cfg.effects.physResistDualColor))
		minPhysResistDual:SetTexture(textureFile)
		minPhysResistDual:SetTextureCoords(unpack(minPhysResistDualTCoords))
		minPhysResistDual:SetDimensions(cfg.barWidth, cfg.barHeight)
		minPhysResistDual:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		minPhysResistDual:SetHidden(true)
		minPhysResistDual.baseTextureCoords = minPhysResistDualTCoords
		-- Creating Major Spell Resist Duality
		local majSpellResistDual= bar.majSpellResistDual or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.majSpellResistDual 	= majSpellResistDual
		bar.majSpellResistDual:ClearAnchors()
	
		local majSpellResistDualTCoords =  deepcopy(textureCfg.coords["spell_major_Dual"])
		majSpellResistDual:SetColor(unpack(cfg.effects.spellResistDualColor))
		majSpellResistDual:SetTexture(textureFile)
		majSpellResistDual:SetTextureCoords(unpack(majSpellResistDualTCoords))
		majSpellResistDual:SetDimensions(cfg.barWidth, cfg.barHeight)
		majSpellResistDual:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		majSpellResistDual:SetHidden(true)
		majSpellResistDual.baseTextureCoords = majSpellResistDualTCoords
		-- Creating Minor Spell Resist Duality
		local minSpellResistDual= bar.minSpellResistDual or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
		bar.minSpellResistDual 	= minSpellResistDual
		bar.minSpellResistDual:ClearAnchors()
	
		local minSpellResistDualTCoords =  deepcopy(textureCfg.coords["spell_minor_Dual"])
		minSpellResistDual:SetColor(unpack(cfg.effects.spellResistDualColor))
		minSpellResistDual:SetTexture(textureFile)
		minSpellResistDual:SetTextureCoords(unpack(minSpellResistDualTCoords))
		minSpellResistDual:SetDimensions(cfg.barWidth, cfg.barHeight)
		minSpellResistDual:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, ratioH)
		minSpellResistDual:SetHidden(true)
		minSpellResistDual.baseTextureCoords = minSpellResistDualTCoords
	end
	-- Creating Regen
	local regen = bar.regen or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
	bar.regen 	= regen
	bar.regen:ClearAnchors()

	local regenTCoords =  deepcopy(textureCfg.coords["regen"])
	regen:SetInheritAlpha(false)
	regen:SetTexture(textureFile)
	regen:SetTextureCoords(
		regenTCoords[1], 
		regenTCoords[2], 
		fillerTCoords[4], 
		fillerTCoords[4])
	regen:SetDimensions(cfg.barWidth, 0)
	regen:SetHidden(true)
	regen.baseTextureCoords = regenTCoords
	-- Creating Degen
	local degen = bar.degen or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
	bar.degen 	= degen
	bar.degen:ClearAnchors()

	local degenTCoords =  deepcopy(textureCfg.coords["degen"])
	degen:SetInheritAlpha(false)
	degen:SetTexture(textureFile)
	degen:SetTextureCoords(
		degenTCoords[1], 
		degenTCoords[2], 
		fillerTCoords[4], 
		fillerTCoords[4])
	degen:SetDimensions(cfg.barWidth, 0)
	degen:SetHidden(true)
	degen.baseTextureCoords = degenTCoords
	-- Creating Bottom border
	local bottomBorderStepSize 	= backgroundStepSize + textureCfg.borderMargin
	local bottomBorderStepSizeT	= textureCfg.barHeight - bottomBorderStepSize - textureCfg.borderSize
	local bottomBorderHeight 	= textureCfg.borderSize * ratioH
	local bottomBorderYOffset 	= -bottomBorderStepSize * ratioH
	local bottomBorderCoords 	= deepcopy(textureCfg.coords["full"])
	bottomBorderCoords[3] 		= bottomBorderCoords[3] + bottomBorderStepSizeT / textureCfg.textureHeight
	bottomBorderCoords[4] 		= bottomBorderCoords[4] - bottomBorderStepSize / textureCfg.textureHeight
	
	local bottomBorder = bar.bottomBorder or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
	bar.bottomBorder = bottomBorder
	bottomBorder:ClearAnchors()
	bottomBorder:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, bottomBorderYOffset)
	bottomBorder:SetTexture(textureFile)
	bottomBorder:SetTextureCoords(unpack(bottomBorderCoords))
	bottomBorder:SetDimensions(cfg.barWidth, bottomBorderHeight)
	-- Creating Top border
	local topBorderStepSizeT 	= backgroundStepSizeT + textureCfg.borderMargin
	local topBorderStepSize 	= textureCfg.barHeight - topBorderStepSizeT - textureCfg.borderSize
	local topBorderHeight 		= bottomBorderHeight
	local topBorderYOffset 		= -topBorderStepSize * ratioH
	local topBorderCoords	 	= deepcopy(textureCfg.coords["full"])
	topBorderCoords[3] 			= topBorderCoords[3] + topBorderStepSizeT / textureCfg.textureHeight
	topBorderCoords[4]			= topBorderCoords[4] - topBorderStepSize / textureCfg.textureHeight
	
	local topBorder = bar.topBorder or WINDOW_MANAGER:CreateControl(nil, bar, CT_TEXTURE)
	bar.topBorder = topBorder
	topBorder:ClearAnchors()
	topBorder:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, topBorderYOffset)
	topBorder:SetTexture(textureFile)
	topBorder:SetTextureCoords(unpack(topBorderCoords))
	topBorder:SetDimensions(cfg.barWidth, topBorderHeight)
	-- Coloring
	-- Display of not border
	if (barCfg.borderShow == true) then
		border:SetColor(unpack(CurvyHud.colorTable["white"]))
		bottomBorder:SetColor(unpack(CurvyHud.colorTable["white"]))
		topBorder:SetColor(unpack(CurvyHud.colorTable["white"]))
	elseif (barCfg.borderShow == false) then
		border:SetColor(unpack(CurvyHud.colorTable["none"]))
		bottomBorder:SetColor(unpack(CurvyHud.colorTable["none"]))
		topBorder:SetColor(unpack(CurvyHud.colorTable["none"]))
	end	
	
	-- Generate GAP for calculating current color of bars
	-- (used later when updating the bar)
	filler.rGap = barCfg.colorMax[1] - barCfg.colorLow[1]
	filler.gGap = barCfg.colorMax[2] - barCfg.colorLow[2]
	filler.bGap = barCfg.colorMax[3] - barCfg.colorLow[3]
	filler.aGap = barCfg.colorMax[4] - barCfg.colorLow[4]
	
	local diffBarCfg = cfg.differentiationBar
	filler.rAllyGap = diffBarCfg.colorMax[1] - diffBarCfg.colorLow[1]
	filler.gAllyGap = diffBarCfg.colorMax[2] - diffBarCfg.colorLow[2]
	filler.bAllyGap = diffBarCfg.colorMax[3] - diffBarCfg.colorLow[3]
	filler.aAllyGap = diffBarCfg.colorMax[4] - diffBarCfg.colorLow[4]
	-- Animating filler and shield
	-- first we create the timeline
	local timeline = ANIMATION_MANAGER:CreateTimeline()
	bar.filler.timeline = timeline
	-- then insert the animation and set its duration and easing function
	local anim = timeline:InsertAnimation(ANIMATION_CUSTOM,  filler)
	bar.filler.anim = anim
	anim:SetDuration(165)
	anim:SetEasingFunction(ZO_EaseOutCubic)
	-- setting some values used in the update function
	anim.height =  bar.filler.baseHeight
	anim.tCoordTop = bar.filler.baseTextureCoords[3]
	anim.baseTCoords = bar.filler.baseTextureCoords
	-- setting some shield values first
	anim.shieldHeight 		= 0
	anim.shieldTCoordBottom = bar.filler.baseTextureCoords[3]
	anim.shieldTCoordTop	= anim.shieldTCoordBottom
	anim:SetUpdateFunction(
		function(self)
			local progress = timeline:GetProgress()
			self.height 	= self.startHeight 		- self.heightOffset		* progress
			self.tCoordTop 	= self.startTCoordTop 	- self.tCoordTopOffset	* progress
			filler:SetHeight(self.height)
			filler:SetTextureCoords(
				self.baseTCoords[1], 
				self.baseTCoords[2], 
				self.tCoordTop, 
				self.baseTCoords[4]
			)
			if((barName == "healthBar" and cfg.visuals.shield.show == true) or (barName == "targetBar" and cfg.targetVisuals.shield.show == true)) then
				self.shieldHeight 		= self.shieldStartHeight 		- self.shieldHeightOffset		* progress
				self.shieldTCoordBottom = self.shieldStartTCoordBottom 	- self.shieldTCoordBottomOffset	* progress
				self.shieldTCoordTop 	= self.shieldStartTCoordTop 	- self.shieldTCoordTopOffset	* progress
			
				bar.shield:SetHeight(self.shieldHeight)
				bar.shield:ClearAnchors()
				if(self.shieldTCoordTop <self.baseTCoords[3]) then
					bar.shield:SetAnchor(unpack(bar.shield.baseAnchor))
					bar.shield:SetTextureCoords(
						self.baseTCoords[1], 
						self.baseTCoords[2], 
						self.baseTCoords[3], 
						self.shieldTCoordBottom
					)
				else
					bar.shield:SetAnchor(BOTTOMLEFT, filler, TOPLEFT, 0, 0)
					bar.shield:SetTextureCoords(
						self.baseTCoords[1], 
						self.baseTCoords[2], 
						self.shieldTCoordTop, 
						self.tCoordTop
					)
				end
			end
			
		end
	)	
	bar.PlayBaseAnim = function(self, barName, newHeight, newTCoordTop, shieldNewHeight, shieldNewTCoordTop, shieldNewTCoordBottom, speed)
		-- setting things up for the update function
		local anim = self.filler.anim
		anim.heightOffset	= anim.height - newHeight
		anim.tCoordTopOffset= anim.tCoordTop - newTCoordTop
		anim.startHeight	= anim.height
		anim.startTCoordTop = anim.tCoordTop
		anim.shieldHeightOffset			= anim.shieldHeight - shieldNewHeight
		anim.shieldTCoordBottomOffset	= anim.shieldTCoordBottom - shieldNewTCoordBottom
		anim.shieldTCoordTopOffset		= anim.shieldTCoordTop - shieldNewTCoordTop
		anim.shieldStartHeight			= anim.shieldHeight
		anim.shieldStartTCoordBottom	= anim.shieldTCoordBottom
		anim.shieldStartTCoordTop		= anim.shieldTCoordTop
		-- if an anim is already playing we stop it
		if(	self.filler.timeline:IsPlaying()) then
			self.filler.timeline:Stop()
		end
		-- Playing the animation
		self.filler.timeline:PlayFromStart()
	end
	-- Go to function animation of degen and regen
	self.CreateRegenAnim(barName, bar, fillerStepSize)
	self.CreateDegenAnim(barName, bar, fillerStepSizeT)
end

-- Build the target nameplate
function CurvyHud:BuildTargetNameplate()	
	-- useful locals
	local cfg 			= CurvyHud.config
	local nameplateCfg 	= CurvyHud.config.targetNameplate
	local valueFontOne
	local valueFontTwo
	-- font nameplateCfguration
	local font 			= string.format("%s|%d|%s",  CurvyHud.fontList[nameplateCfg.fontName],  nameplateCfg.fontSize,  "thick-outline")
	local fontCaption 	= string.format("%s|%d|%s",  CurvyHud.fontList[nameplateCfg.fontName],  nameplateCfg.fontSize-4,  "thick-outline")
	local iconSize 		= nameplateCfg.fontSize * 1.7
	local iconEquiSize 	= nameplateCfg.fontSize * 1.4
	local bossLength 	= nameplateCfg.fontSize * 3.8
	local bossWidth 	= nameplateCfg.fontSize * 1.2
	--anchors and offsets nameplateCfguration depending on alignment
	local top 			= BOTTOM
	local topRelative 	= TOP
	local bottom 		= TOP
	local bottomRelative= BOTTOM
	-- Creating and positioning the target nameplate container
	local container 		= self.targetNameplate or WINDOW_MANAGER:CreateControl("CURVY_Target_Nameplate", self.topControl, CT_CONTROL)
	self.targetNameplate 	= container
	nameplateCfg.anchor[2] 	= GuiRoot
	container:ClearAnchors()
	container:SetAnchor(unpack(nameplateCfg.anchor))
	-- Creating Name of target
	local name = container.name or WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
	name:SetFont(font)
	name:ClearAnchors()
	name:SetAnchor(CENTER, container, CENTER, 0, -5)
	name:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	name:SetVerticalAlignment(TEXT_ALIGN_TOP)
	name:SetHeight(nameplateCfg.fontSize +10)
	container.name = name
	-- Creating class icon
	local classIcon = container.classIcon or  WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
	classIcon:ClearAnchors()
	classIcon:SetDimensions(iconEquiSize, iconEquiSize)
	classIcon:SetAnchor(top, name, topRelative, 0, nameplateCfg.fontSize * (-1))
	container.classIcon = classIcon
	-- Creating Level of target
	local level = container.level or WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
	level:SetFont(font)
	level:ClearAnchors()
	level:SetAnchor(bottom, name, bottomRelative, 0, nameplateCfg.fontSize * (-0.2))
	level:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	level:SetVerticalAlignment(TEXT_ALIGN_TOP)
	container.level = level
	-- Creating Classe icon when Level is no longer present
	local nolevel = container.nolevel or WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
	nolevel:ClearAnchors()
	nolevel:SetDimensions(iconEquiSize, iconEquiSize)
	nolevel:SetAnchor(top, name, topRelative, 0, nameplateCfg.fontSize * (3.2))		
	container.nolevel = nolevel
	-- Creating race icon
	local raceIcon = container.raceIcon or  WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
	raceIcon:ClearAnchors()
	raceIcon:SetDimensions(iconEquiSize, iconEquiSize)
	raceIcon:SetAnchor(bottom, level, bottomRelative, 0, nameplateCfg.fontSize * (-0.2))
	container.raceIcon = raceIcon
	-- Creating Caption of target
	local caption = container.caption or WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
	caption:ClearAnchors()
	caption:SetAnchor(top, name, topRelative, 0, nameplateCfg.fontSize * (0.4))
	caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	caption:SetVerticalAlignment(TEXT_ALIGN_TOP)
	caption:SetFont(fontCaption)
	container.caption = caption
	-- Creation of race icon when Caption is no longer present
	local nocaption = container.nocaption or WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
	nocaption:ClearAnchors()
	nocaption:SetDimensions(iconEquiSize, iconEquiSize)
	nocaption:SetAnchor(top, name, topRelative, 0, nameplateCfg.fontSize * (0.3))	
	container.nocaption = nocaption
	-- Creating AvA rank icon
	local avaRankIcon =  container.avaRankIcon or WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
	avaRankIcon:ClearAnchors()
	avaRankIcon:SetDimensions(iconSize, iconSize)
	avaRankIcon:SetAnchor(LEFT, name, RIGHT, 0,  nameplateCfg.fontSize * (0.15))
	container.avaRankIcon = avaRankIcon
	-- Creating alliance icon
	local allianceIcon = container.allianceIcon or  WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
	allianceIcon:SetDimensions(iconSize, iconSize)
	allianceIcon:ClearAnchors()
	allianceIcon:SetAnchor(RIGHT, name, LEFT, 0,  nameplateCfg.fontSize * (0.2))
	container.allianceIcon = allianceIcon
	-- creatin monster difficulty icon
	local monsterDiff = container.monsterDiff or WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
	monsterDiff:SetDimensions(bossLength, bossWidth)
	monsterDiff:ClearAnchors()
	monsterDiff:SetAnchor(TOP, name, BOTTOM, 0, 10)
	container.monsterDiff = monsterDiff

	container:SetDimensions(325, 150)
	
	self.movableFrames.targetNameplate = container
	self.movableFrames.targetNameplate.anchorConfig = nameplateCfg.anchor
end


-- Build the text of the given bar
function CurvyHud:BuildTextValues(barName)

	local cfg 	= CurvyHud.config
	local bar 	= CurvyHud.bars[barName]
	local barCfg= bar.config
	local font 	= string.format("%s|%d|%s",  CurvyHud.fontList[barCfg.fontName],  barCfg.fontSize,  "thick-outline")
	-- creating the container
	local container 		= bar.textContainer or  WINDOW_MANAGER:CreateControl(nil, self.topControl, CT_CONTROL)
	bar.textContainer 		= container
	barCfg.textAnchor[2]	= GuiRoot
	container:ClearAnchors()
	container:SetAnchor(unpack(barCfg.textAnchor))
	-- creating label
	local text 		= container.text or WINDOW_MANAGER:CreateControl(nil,  container,  CT_LABEL)
	container.text 	= text
	text:SetFont(font)
	text:ClearAnchors()
	text:SetAnchor(CENTER)
	text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	text:SetVerticalAlignment(TEXT_ALIGN_CENTER)	
	text:SetText(CurvyHud.FormatTextValues(barCfg.textFormat, 1000, 1000, 100))

	container:SetDimensions(265,40)
	-- Adding text container to movable frames
	self.movableFrames[barName.."Text"] 				= container
	self.movableFrames[barName.."Text"].anchorConfig 	= barCfg.textAnchor
	-- if healthBar or targetBar,  creating the shield text values
	if(barName == "healthBar" or barName == "targetBar") then
		local shieldCfg	= (barName == "targetBar" and cfg.targetVisuals.shield or cfg.visuals.shield)
		local frameName = (barName == "targetBar" and "targetShieldText" or "shieldText")
		local shieldFont 	= string.format("%s|%d|%s",  CurvyHud.fontList[shieldCfg.fontName],  shieldCfg.fontSize,  "thick-outline")
		-- creating the shield text container
		local container 			= bar.shield.textContainer or  WINDOW_MANAGER:CreateControl(nil, self.topControl, CT_CONTROL)
		bar.shield.textContainer	= container
		shieldCfg.textAnchor[2]		= GuiRoot
		container:SetAnchor(unpack(shieldCfg.textAnchor))
		-- creating label
		local text		= container.text or WINDOW_MANAGER:CreateControl(nil,  container,  CT_LABEL)
		container.text 	= text
		text:SetColor(unpack(shieldCfg.textColor))
		text:SetFont(shieldFont)
		text:ClearAnchors()
		text:SetAnchor(CENTER)
		text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		text:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		text:SetText(CurvyHud.FormatTextValues(shieldCfg.textFormat, 1000))
		text:SetHidden(true)
		
		container:SetDimensions(text:GetDimensions())
		self.movableFrames[frameName] 				= container
		self.movableFrames[frameName].anchorConfig 	= shieldCfg.textAnchor
	end
end

function CurvyHud:BuildInteractionPrompt()

	local container = self.interactionPrompt or WINDOW_MANAGER:CreateTopLevelWindow("CURVY_InteractionPrompt")
	CurvyHud.config.interactionPrompt.anchor[2] = GuiRoot
	container:ClearAnchors()
	container:SetAnchor(unpack(CurvyHud.config.interactionPrompt.anchor))
	container:SetDimensions(300, 75)
	-- Interaction prompt global
	ZO_ReticleContainerInteract:ClearAnchors()
	ZO_ReticleContainerInteract:SetAnchor(TOP, container, TOP, 0, 0)
	ZO_ReticleContainerInteract:SetWidth(300)
	-- Name of NPC and Items
	ZO_ReticleContainerInteractContext:ClearAnchors()
	ZO_ReticleContainerInteractContext:SetAnchor(CENTER, ZO_ReticleContainerInteract, CENTER, 0, -5)
	ZO_ReticleContainerInteractContext:SetVerticalAlignment(TEXT_ALIGN_TOP)
	ZO_ReticleContainerInteractContext:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	ZO_ReticleContainerInteractContext:SetWidth(300)
	-- Button of NPC/Ietms interaction
	ZO_ReticleContainerInteractKeybindButtonNameLabel:ClearAnchors()
	ZO_ReticleContainerInteractKeybindButtonNameLabel:SetAnchor(TOP, ZO_ReticleContainerInteractContext, BOTTOM, 0, 0)
	ZO_ReticleContainerInteractKeybindButtonNameLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
	ZO_ReticleContainerInteractKeybindButtonNameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	-- Name of flags,  signs,  etc...
	ZO_ReticleContainerNonInteract:ClearAnchors()
	ZO_ReticleContainerNonInteract:SetAnchor(TOP, container, TOP, 0, 0)
	ZO_ReticleContainerNonInteractText:SetVerticalAlignment(TEXT_ALIGN_TOP)
	ZO_ReticleContainerNonInteractText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	-- creating label
	local text = container.text or WINDOW_MANAGER:CreateControl(nil,  container,  CT_LABEL)
	container.text 	= text
	text:ClearAnchors()
	text:SetFont("ZoFontWinH4")
	text:SetAnchor(CENTER, container, CENTER)
	text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	text:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	text:SetText(L.Move_interactionPrompt)
	text:SetHidden(true)
	
	self.interactionPrompt = container
	self.movableFrames.interactionPrompt = container
	self.movableFrames.interactionPrompt.anchorConfig = CurvyHud.config.interactionPrompt.anchor
end

function CurvyHud:BuildPlayerinteractionPrompt()

	local container = self.playerinteractionPrompt or WINDOW_MANAGER:CreateTopLevelWindow("CURVY_PlayerinteractionPrompt")
	CurvyHud.config.playerinteractionPrompt.anchor[2] = GuiRoot
	container:ClearAnchors()
	container:SetAnchor(unpack(CurvyHud.config.playerinteractionPrompt.anchor))
	container:SetDimensions(300, 75)
	-- Player to player global 
	ZO_PlayerToPlayerAreaPromptContainer:ClearAnchors()
	ZO_PlayerToPlayerAreaPromptContainer:SetAnchor(TOP, container, TOP, 0, 0)
	-- Name and Account for player targeted <-- SetHidden don"t work for it
	ZO_PlayerToPlayerAreaPromptContainerTarget:ClearAnchors()
	ZO_PlayerToPlayerAreaPromptContainerTarget:SetAnchor(TOP, ZO_PlayerToPlayerAreaPromptContainer, BOTTOM, 0, 5)
	ZO_PlayerToPlayerAreaPromptContainerTarget:SetVerticalAlignment(TEXT_ALIGN_TOP)
	ZO_PlayerToPlayerAreaPromptContainerTarget:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	-- Button of Player to player interaction
	ZO_PlayerToPlayerAreaPromptContainerActionAreaActionKeybindButtonNameLabel:ClearAnchors()
	ZO_PlayerToPlayerAreaPromptContainerActionAreaActionKeybindButtonNameLabel:SetAnchor(TOP, ZO_PlayerToPlayerAreaPromptContainerTarget, BOTTOM, 0, 0)
	ZO_PlayerToPlayerAreaPromptContainerActionAreaActionKeybindButtonNameLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
	ZO_PlayerToPlayerAreaPromptContainerActionAreaActionKeybindButtonNameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	-- Creating label
	local text		= container.text or WINDOW_MANAGER:CreateControl(nil,  container,  CT_LABEL)
	container.text = text
	text:ClearAnchors()
	text:SetFont("ZoFontWinH4")
	text:SetAnchor(CENTER, container, CENTER)
	text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	text:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	text:SetText(L.Move_PlayerinteractionPrompt)
	text:SetHidden(true)
	
	self.playerinteractionPrompt = container
	self.movableFrames.playerinteractionPrompt = container
	self.movableFrames.playerinteractionPrompt.anchorConfig = CurvyHud.config.playerinteractionPrompt.anchor
end

function CurvyHud:BuildLowAttributes()

	local container = self.lowAttributes or WINDOW_MANAGER:CreateControl("CURVY_LowAttributes", self.topControl, CT_CONTROL)
	CurvyHud.config.lowAttributes.anchor[2] 	= GuiRoot
	container:ClearAnchors()
	container:SetDimensions(150, 150)
	container:SetAnchor(unpack(CurvyHud.config.lowAttributes.anchor))
	
	local lowAttribFont = string.format("%s|%d|%s", CurvyHud.fontList[CurvyHud.config.lowAttributes.fontName], CurvyHud.config.lowAttributes.fontSize, "thick-outline")
	-- Creating label for  health alert
	local health 	= container.health or WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
	health:ClearAnchors()
	health:SetAnchor(CENTER, container, CENTER) 
	health:SetFont(lowAttribFont)
	health:SetColor(unpack(CurvyHud.config.healthBar.colorLow))
	health:SetText(L.LowAttribHealth)
	health:SetHidden(true)
	container.health = health
	-- Creating label for  stamina alert
	local stamina	= container.stamina or WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
	stamina:ClearAnchors()
	stamina:SetAnchor(CENTER, container, CENTER, 0, (-CurvyHud.config.lowAttributes.fontSize * 1.5))
	stamina:SetFont(lowAttribFont)
	stamina:SetColor(unpack(CurvyHud.config.staminaBar.colorLow))
	stamina:SetText(L.LowAttribStamina)
	stamina:SetHidden(true)
	container.stamina = stamina
	-- Creating label for magicka alert
	local magicka	= container.magicka or WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
	magicka:ClearAnchors()
	magicka:SetAnchor(CENTER, container, CENTER, 0, (CurvyHud.config.lowAttributes.fontSize * 1.5)) 
	magicka:SetFont(lowAttribFont)
	magicka:SetColor(unpack(CurvyHud.config.magickaBar.colorLow))
	magicka:SetText(L.LowAttribMagicka)
	magicka:SetHidden(true)
	container.magicka = magicka
	
	self.lowAttributes = container
	self.movableFrames.lowAttributes = container
	self.movableFrames.lowAttributes.anchorConfig = CurvyHud.config.lowAttributes.anchor
end

-- Container of Combat Tips
function CurvyHud:BuildCombatTips()

	local container = self.combatTips or WINDOW_MANAGER:CreateControl("CURVY_CombatTips", self.topControl, CT_CONTROL)
	CurvyHud.config.combatTips.anchor[2] 	= GuiRoot
	container:ClearAnchors()
	container:SetDimensions(200, 200)
	container:SetAnchor(unpack(CurvyHud.config.combatTips.anchor))
	
	local tipsFont	= string.format("%s|%d|%s", CurvyHud.fontList[CurvyHud.config.combatTips.fontName], CurvyHud.config.combatTips.fontSize, "thick-outline")
	-- Creating label for block text alert
	local block	= container.block or WINDOW_MANAGER:CreateControl(nil,  container, CT_LABEL)
	block:SetFont(tipsFont)
	block:SetColor(unpack(CurvyHud.config.combatTips.blockColor))
	block:SetText(L.TipsBloc)
	block:SetAnchor(CENTER, container, CENTER, 0, (-CurvyHud.config.combatTips.fontSize * 1.7))
	block:SetHidden(true)
	container.block = block
	-- Creating label for exploit text alert
	local exploit	= container.exploit or WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
	exploit:ClearAnchors()
	exploit:SetFont(tipsFont)
	exploit:SetColor(unpack(CurvyHud.config.combatTips.exploitColor))
	exploit:SetText(L.TipsExploit)
	exploit:SetAnchor(CENTER, container, CENTER, 0, (CurvyHud.config.combatTips.fontSize * 0.6)) 
	exploit:SetHidden(true)
	container.exploit = exploit
	-- Creating label for interrupt text alert
	local interrupt	= container.interrupt or WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
	interrupt:ClearAnchors()
	interrupt:SetFont(tipsFont)
	interrupt:SetColor(unpack(CurvyHud.config.combatTips.interruptColor))
	interrupt:SetText(L.TipsInterrupt)
	interrupt:SetAnchor(CENTER, container, CENTER, 0, (-CurvyHud.config.combatTips.fontSize * 0.6)) 
	interrupt:SetHidden(true)
	container.interrupt = interrupt	
	-- Creating lable of dodge text alert
	local dodge		= container.dodge or WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
	dodge:ClearAnchors()
	dodge:SetFont(tipsFont)
	dodge:SetColor(unpack(CurvyHud.config.combatTips.dodgeColor))
	dodge:SetText(L.TipsDodge)
	dodge:SetAnchor(CENTER, container, CENTER, 0, (CurvyHud.config.combatTips.fontSize * 1.7)) 
	dodge:SetHidden(true)
	container.dodge = dodge
	
	self.combatTips = container
	self.movableFrames.combatTips = container
	self.movableFrames.combatTips.anchorConfig = CurvyHud.config.combatTips.anchor
end

function CurvyHud:BuildTaunt()

	local container = self.taunt or WINDOW_MANAGER:CreateControl("CURVY_Taunt", self.topControl, CT_CONTROL)
	CurvyHud.config.targetVisuals.taunt.anchor[2] 	= GuiRoot
	container:ClearAnchors()
	container:SetDimensions(42, 32)
	container:SetAnchor(unpack(CurvyHud.config.targetVisuals.taunt.anchor))

	-- Creating texture
	local icon	= container.icon or WINDOW_MANAGER:CreateControl(nil,  container, CT_TEXTURE)
	icon:ClearAnchors()
	icon:SetAnchor(CENTER, container, CENTER, 0, 0)
	icon:SetDimensions(28, 28)
	icon:SetTexture(CurvyHud.name.."/textures/icons/taunt.dds")
	container.icon = icon
	
	local font	= string.format("%s|%d|%s", CurvyHud.fontList[CurvyHud.config.clepsydre.fontName], CurvyHud.config.clepsydre.fontSize, "thick-outline")		
	local timer = container.clockTime or WINDOW_MANAGER:CreateControl(nil,  container,  CT_LABEL)
	timer:ClearAnchors()
	timer:SetFont(font)
	timer:SetAnchor(CENTER, container, CENTER, 30, 0)
	container.timer	= timer
	
	self.taunt = container
	self.movableFrames.taunt = container
	self.movableFrames.taunt.anchorConfig = CurvyHud.config.targetVisuals.taunt.anchor
end

function CurvyHud.CreateRegenAnim(barName, bar,  fillerStepSize)

	local cfg 			= CurvyHud.config
	local regen 		= bar.regen
	local filler 		= bar.filler
	local fillerHeight 	= filler.baseHeight
	local fillerTCoords = bar.filler.baseTextureCoords
	local regenTCoords 	= bar.regen.baseTextureCoords
	
	local timeline = regen.timeline or ANIMATION_MANAGER:CreateTimeline()
	regen.timeline = timeline
	timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, 100000)
	
	local anim = regen.anim or timeline:InsertAnimation(ANIMATION_CUSTOM, regen)
	regen.anim = anim
	
	local fillerTHeight = fillerTCoords[4] - fillerTCoords[3]
	
	anim.startCoord = fillerHeight
	anim.startTCoord= fillerTCoords[4]
	anim.stopCoord 	= fillerHeight / 2 - 30
	anim.stopTCoord = anim.stopCoord / cfg.barHeight	
	anim.height 	= fillerHeight / 2 - 30
	anim.arrowSpan 	= math.min(fillerHeight / 6, anim.height)
	anim.arrowTSpan = math.min(fillerTHeight / 6, anim.height / cfg.barHeight)
	anim.baseAnchor = {BOTTOMLEFT, bar, BOTTOMLEFT, 0, -fillerStepSize}
	
	regen:SetAnchor(unpack(anim.baseAnchor))
	-- this function is used to set a time between each loop (the loopOffset value,  in ms)
	-- anim.baseDuration is equal to the actual time, in ms, the animation takes to run its course (i.e. from starting point to top point)
	function anim:SetLoopOffset(offset)
		self.loopOffset = offset
		self.offsetRatio = (self.baseDuration + self.loopOffset) / self.baseDuration
		self:SetDuration(self.baseDuration * self.offsetRatio)
	end
	anim.baseDuration = 800
	anim:SetLoopOffset(0)
	anim.expanding = true
	anim:SetUpdateFunction(
		function(self)
			local progress = timeline:GetProgress() * self.offsetRatio
			if(progress >= 1) then
				regen:SetHeight(0)
				regen:SetTextureCoords(
					regenTCoords[1], 
					regenTCoords[2], 
					self.startTCoord, 
					self.startTCoord
				)
				regen:ClearAnchors()
				regen:SetAnchor(unpack(self.baseAnchor))
				self.expanding = true
			else
				local actualSpan = math.ceil(regen:GetHeight())
				local tCoordTop = self.startTCoord - (self.stopTCoord + self.arrowTSpan) * progress
				local tCoordBottom = tCoordTop + self.arrowTSpan
				
				local yOffset = (self.stopCoord+self.arrowSpan) * progress - self.arrowSpan
				
				if(actualSpan < self.arrowSpan and self.expanding) then
					regen:SetTextureCoords(
						regenTCoords[1], 
						regenTCoords[2], 
						tCoordTop, 
						self.startTCoord
					)
					regen:SetHeight(math.min((self.stopCoord+self.arrowSpan) * progress), self.arrowSpan)
					regen:ClearAnchors()
					regen:SetAnchor(unpack(self.baseAnchor))
				elseif(actualSpan >= self.arrowSpan and tCoordTop >= self.startTCoord - self.stopTCoord) then
					self.expanding = false
					regen:SetHeight(self.arrowSpan)
					regen:SetTextureCoords(
						regenTCoords[1], 
						regenTCoords[2], 
						tCoordTop, 
						tCoordBottom 
					)
					regen:ClearAnchors()
					regen:SetAnchor(
						self.baseAnchor[1], 
						self.baseAnchor[2], 
						self.baseAnchor[3], 
						self.baseAnchor[4], 
						self.baseAnchor[5]-yOffset
					)
				else
					self.expanding = false
					regen:SetTextureCoords(
						regenTCoords[1], 
						regenTCoords[2], 
						self.startTCoord - self.stopTCoord, 
						tCoordBottom 
					)
					regen:SetHeight(self.stopCoord - yOffset )
					regen:ClearAnchors()
					regen:SetAnchor(
						self.baseAnchor[1], 
						self.baseAnchor[2], 
						self.baseAnchor[3], 
						self.baseAnchor[4], 
						self.baseAnchor[5]-yOffset
					)
				end
			end			
		end
	)
end

function CurvyHud.CreateDegenAnim(barName, bar, fillerStepSizeT)

	local cfg 			= CurvyHud.config
	local degen 		= bar.degen
	local filler 		= bar.filler
	local fillerHeight 	= filler.baseHeight
	local fillerTCoords = bar.filler.baseTextureCoords
	local degenTCoords 	= bar.degen.baseTextureCoords
	
	local timeline = degen.timeline or ANIMATION_MANAGER:CreateTimeline()
	degen.timeline = timeline
	timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, 100000)
	
	local anim = degen.anim or timeline:InsertAnimation(ANIMATION_CUSTOM, degen)
	degen.anim = anim
	
	local fillerTHeight = fillerTCoords[4] - fillerTCoords[3]
	
	anim.startCoord = fillerHeight
	anim.startTCoord= fillerTCoords[3]
	anim.stopCoord 	= fillerHeight / 2 - 30
	anim.stopTCoord = anim.stopCoord / cfg.barHeight	
	anim.height 	= fillerHeight / 2 - 30
	anim.arrowSpan 	= math.min(fillerHeight / 6, anim.height)
	anim.arrowTSpan = math.min(fillerTHeight / 6, anim.height / cfg.barHeight)
	anim.baseAnchor = {TOPLEFT, bar, TOPLEFT, 0, fillerStepSizeT}
	
	degen:SetAnchor(unpack(anim.baseAnchor))
	-- this function is used to set a time between each loop (the loopOffset value,  in ms)
	-- anim.baseDuration is equal to the actual time, in ms, the animation takes to run its course (i.e. from starting point to top point)
	function anim:SetLoopOffset(offset)
		self.loopOffset = offset
		self.offsetRatio = (self.baseDuration + self.loopOffset) / self.baseDuration
		self:SetDuration(self.baseDuration * self.offsetRatio)
	end
	anim.baseDuration = 800
	anim:SetLoopOffset(0)
	anim.expanding = true
	anim:SetUpdateFunction(
		function(self)
			local progress = timeline:GetProgress() * self.offsetRatio
			if(progress >= 1) then
				degen:SetHeight(0)
				degen:SetTextureCoords(
					degenTCoords[1], 
					degenTCoords[2], 
					self.startTCoord, 
					self.startTCoord
				)
				degen:ClearAnchors()
				degen:SetAnchor(unpack(self.baseAnchor))
				self.expanding = true
			else
				local actualSpan 	= math.ceil(degen:GetHeight())
				local tCoordBottom 	= self.startTCoord + (self.stopTCoord + self.arrowTSpan) * progress
				local tCoordTop 	= tCoordBottom - self.arrowTSpan
				
				local yOffset = (self.stopCoord + self.arrowSpan) * progress -self.arrowSpan
				if(actualSpan < self.arrowSpan and self.expanding) then
					degen:SetTextureCoords(
						degenTCoords[1], 
						degenTCoords[2], 
						self.startTCoord, 
						tCoordBottom
					)
					degen:SetHeight(math.min((self.stopCoord+self.arrowSpan) * progress), self.arrowSpan)
					degen:ClearAnchors()
					degen:SetAnchor(unpack(self.baseAnchor))
				elseif(actualSpan >= self.arrowSpan and tCoordBottom <= self.startTCoord + self.stopTCoord) then
					self.expanding = false
					degen:SetHeight(self.arrowSpan)
					degen:SetTextureCoords(
						degenTCoords[1], 
						degenTCoords[2], 
						tCoordTop, 
						tCoordBottom 
					)
					degen:ClearAnchors()
					degen:SetAnchor(
						self.baseAnchor[1], 
						self.baseAnchor[2], 
						self.baseAnchor[3], 
						self.baseAnchor[4], 
						self.baseAnchor[5]+yOffset
					)
				else
					self.expanding = false
					degen:SetTextureCoords(
						degenTCoords[1], 
						degenTCoords[2], 
						tCoordTop, 
						self.startTCoord+self.stopTCoord
					)
					degen:SetHeight(self.stopCoord - yOffset )
					degen:ClearAnchors()
					degen:SetAnchor(
						self.baseAnchor[1], 
						self.baseAnchor[2], 
						self.baseAnchor[3], 
						self.baseAnchor[4], 
						self.baseAnchor[5]+yOffset
					)
				end
			end			
		end
	)
end

-- Creation of Harven - Harven"s Bag Space addon
function CurvyHud:BagSlot()
	
	local list = GetControl(LOOT_WINDOW_FRAGMENT.control:GetNamedChild("AlphaContainer"), "List")
	local bg = GetControl(LOOT_WINDOW_FRAGMENT.control:GetNamedChild("AlphaContainer"), "BG")
	local button1 = GetControl(LOOT_WINDOW_FRAGMENT.control:GetNamedChild("AlphaContainer"), "Button1")
	local button2 = GetControl(LOOT_WINDOW_FRAGMENT.control:GetNamedChild("AlphaContainer"), "Button2")

	bg:SetHeight(562)
	button2:ClearAnchors()
	button2:SetAnchor(TOPLEFT,  button1,  BOTTOMLEFT,  0,  4)

	local freeSlots = WINDOW_MANAGER:CreateControl("Curvy_FreeSlots", LOOT_WINDOW_FRAGMENT.control, CT_LABEL)
	freeSlots:ClearAnchors()
	freeSlots:SetAnchor(TOPCENTER, list, TOPCENTER, 90, -85)
	freeSlots:SetFont("ZoFontGameLargeBold")
	freeSlots:SetColor(ZO_NORMAL_TEXT:UnpackRGB())

	LOOT_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			freeSlots:SetHidden(true)
		elseif newState == SCENE_SHOWN then
			freeSlots:SetHidden(false)
			local numUsedSlots = 0
			local numSlots = 0
			if GetNumBagUsedSlots then
				numUsedSlots = GetNumBagUsedSlots(INVENTORY_BACKPACK)
				numSlots = GetBagSize(INVENTORY_BACKPACK)
			else
				numUsedSlots = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].numUsedSlots
				numSlots = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].numSlots
			end
		
			if numUsedSlots < numSlots then
				freeSlots:SetText(zo_strformat(SI_INVENTORY_BACKPACK_REMAINING_SPACES, numUsedSlots, numSlots))
			else
				freeSlots:SetText(zo_strformat(SI_INVENTORY_BACKPACK_COMPLETELY_FULL, numUsedSlots, numSlots))
			end
		end
	end)
end

function CurvyHud:BuildReticle()

	local container = self.reticle or WINDOW_MANAGER:CreateTopLevelWindow("CURVY_Reticle")
	CurvyHud.config.reticleOption.anchor[2] = GuiRoot
	container:ClearAnchors()
	container:SetAnchor(unpack(CurvyHud.config.reticleOption.anchor))
	container:SetDimensions(64, 64)

	local center =  container.center or WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
	center:ClearAnchors()
	center:SetAnchor(CENTER, container, CENTER, 0, 0)
	center:SetTexture(CurvyHud.name.."/textures/icons/reticleCenter.dds")
	center:SetDimensions(50, 32)
	container.center = center
	
	local borders =  container.borders or WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
	borders:ClearAnchors()
	borders:SetAnchor(CENTER, container, CENTER, 0, 0)
	borders:SetTexture(CurvyHud.name.."/textures/icons/reticleBorders.dds")
	borders:SetDimensions(30, 25)
	container.borders = borders
	
	local alert =  container.alert or WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
	alert:ClearAnchors()
	alert:SetAnchor(CENTER, container, CENTER, 0, -10)
	alert:SetTexture(CurvyHud.name.."/textures/icons/reticleAlerte.dds")
	alert:SetDimensions(50, 32)
	container.alert = alert
	
	self.reticle = container
end

function CurvyHud:BuildClepsydre()

	local font	= string.format("%s|%d|%s", CurvyHud.fontList[CurvyHud.config.clepsydre.fontName], CurvyHud.config.clepsydre.fontSize, "thick-outline")
	local fontTimer	= string.format("%s|%d|%s", CurvyHud.fontList[CurvyHud.config.clepsydre.fontName], CurvyHud.config.clepsydre.fontSize * 0.66, "thick-outline")	
	
	local container = self.clepsydre or WINDOW_MANAGER:CreateTopLevelWindow("CURVY_Clepsydre")
	CurvyHud.config.clepsydre.anchor[2] = GuiRoot
	container:ClearAnchors()
	container:SetAnchor(unpack(CurvyHud.config.clepsydre.anchor))
	container:SetDimensions(120, 60)

	local clockTime = container.clockTime or WINDOW_MANAGER:CreateControl(nil,  container,  CT_LABEL)
	clockTime:ClearAnchors()
	clockTime:SetFont(font)
	clockTime:SetColor(unpack(CurvyHud.config.clepsydre.color))
	clockTime:SetAnchor(CENTER, container, CENTER, 0, 12)
	clockTime:SetAlpha(CurvyHud.config.clepsydre.alpha)	
	container.clockTime	= clockTime
	
	local iconTime =  container.iconTime or WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
	iconTime:ClearAnchors()
	iconTime:SetAnchor(TOP, clockTime, TOP, 0, -20)
	iconTime:SetTexture(CurvyHud.name.."/textures/icons/clock.dds")
	iconTime:SetDimensions(20, 20)
	iconTime:SetAlpha(CurvyHud.config.clepsydre.alpha)
	container.iconTime = iconTime
	
	local clockTimer = container.clockTimer or WINDOW_MANAGER:CreateControl(nil,  container,  CT_LABEL)
	clockTimer:ClearAnchors()
	clockTimer:SetFont(fontTimer)
	clockTimer:SetColor(unpack(CurvyHud.config.clepsydre.chronocolor))
	clockTimer:SetAnchor(BOTTOM, clockTime, BOTTOM, 0, 20)
	clockTimer:SetAlpha(CurvyHud.config.clepsydre.alpha)	
	container.clockTimer	= clockTimer
	
	self.clepsydre = container
	self.movableFrames.clepsydre = container
	self.movableFrames.clepsydre.anchorConfig = CurvyHud.config.clepsydre.anchor
end

function CurvyHud:ControlButttons(buttons, enable)

	if (enable) then
		bool = true
		state = BSTATE_NORMAL
	else
		bool = false
		state = BSTATE_DISABLED	
	end
	if (buttons == "newButton") then
		CurvyHud.button.new = bool
		CurvyHudOptions_cfgBtnNewBtn.button:SetState(state)
	elseif (buttons == "saveButton") then
		CurvyHud.button.save = bool
		CurvyHudOptions_cfgBtnSaveBtn.button:SetState(state)
	elseif (buttons == "loadButton") then
		CurvyHud.button.load = bool
		CurvyHudOptions_cfgBtnLoadBtn.button:SetState(state)
	end
end

function CurvyHud:SlashCommands()

	SLASH_COMMANDS["/curvy_move"] = function(active)
		if (active == "on") then
			CurvyHud:ToggleMoveFramesMode(true)
		elseif (active == "off") then
			CurvyHud:ToggleMoveFramesMode(false)
		else
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyCmdErr..L.CurvyInf)
		end
	end
	SLASH_COMMANDS["/curvy"] = function(active)
		if (active == "?") then
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyFrames..L.CurvySlash)
			CHAT_SYSTEM:AddMessage(L.CurvySlashTow)
		else
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyCmdErr..L.CurvyInfo)
		end
	end
	SLASH_COMMANDS["/curvy_raz"] = function(active)
		if (active) then
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.DeadCountRAZ)
			CurvyHud.state.playerDeadCount	= 0
		end
	end
	SLASH_COMMANDS["/curvy_chrono"] = function(active)
		if (active == "mano") then
			CurvyHud.config.clepsydre.automaticChrono = "mano"
		elseif (active == "auto") then
			CurvyHud.config.clepsydre.automaticChrono = "auto"
		elseif (active == "sp") then
			CurvyHud.config.clepsydre.automaticChrono = "sp"
		else
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyCmdErr..L.CurvyInftwo)
		end
		CurvyHud:OnChatChronoMode()
		CurvyHud.state.chronoStart 		= "stop"	
	end
	-- "Slash 404" original mode by CaptainBlagbird
	-- Replace ZO_Alert function when your slash command are not correctly
	local chatcmderror = ZO_Alert
	ZO_Alert = function(category,  soundId,  message,  ...)
		if (category == UI_ALERT_CATEGORY_ALERT) and (message == SI_ERROR_INVALID_COMMAND) then
			CHAT_SYSTEM:AddMessage(zo_strformat(message,  ...))
		end
		return chatcmderror(category,  soundId,  message,  ...)
	end
end

function CurvyHud:WelcomeInGame()

	local accuntText	= zo_strformat(SI_TOOLTIP_UNIT_NAME, GetUnitDisplayName("player"))
	local seconds 		= GetSecondsPlayed()
	local daysPlayed 	= math.floor(seconds / 86400)
	local hoursPlayed 	= math.floor((seconds / 3600) - (daysPlayed * 24))
	local minutesPlayed = math.floor((seconds  - ((hoursPlayed * 3600) + (daysPlayed * 86400))) / 60)
	CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyWelcome..accuntText.."|cFFFFFF - CurvyHud version "..CurvyHud.version)
	CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.WelcomeBegin..CurvyHud.avatarName..L.WelcomeTimeWithAvatar..daysPlayed..L.WelcomeDays..hoursPlayed..L.WelcomeHours..minutesPlayed..L.WelcomeMinutes)
	CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyChat)
	CurvyHud.location.init  = GetUnitZoneIndex("player")
--	CurvyHud:DungeonInformationChat()
	if (CurvyHud.config.covertChatIndic) then
		if (not CurvyHud.state.isDisguise and not CurvyHud.state.stealthState) then
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyDisguiseOff)
		end
	end
	CurvyHud.state.chronoStart 		= "stop"
end

function CurvyHud:OnChatChronoMode()
	
	if (CurvyHud.state.chronoStart ~= "start") then
		if (CurvyHud.config.clepsydre.automaticChrono == "auto") then
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.ClepsydreChronoRAZ..L.clepsydreChronoAuto)
		elseif (CurvyHud.config.clepsydre.automaticChrono == "mano") then
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.ClepsydreChronoRAZ..L.clepsydreChronoMano)
		elseif (CurvyHud.config.clepsydre.automaticChrono == "sp") then
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.ClepsydreChronoRAZ..L.clepsydreChronoSP)
		end
	end
end

function CurvyHud:ChonoAutoMode(mode)

	if (mode == "auto") then
		local bossDead 	= IsUnitDead("boss1" or "boss2" or "boss3" or "boss4"  or "boss5" or "boss6")
		if (CurvyHud.state.bossHere and not bossDead) then
			if (CurvyHud.state.chronoStart ~= "start") then
				CurvyHud.state.chronoStart = "start"
				CurvyHud.state.countButton = 0
				CurvyHud:UpdateChrono()
			end
		end
	end
	
	if (mode == "sp") then
		if (CurvyHud.state.chronoStart ~= "start") then
			CurvyHud.state.chronoStart = "start"
			CurvyHud.state.countButton = 0
			CurvyHud:UpdateChrono()
		end
	end
end

function CurvyHud:DeadInformation()

	math.randomseed (os.time ())
	math.random (); math.random (); math.random ()
	local x = CurvyHud.state.playerDeadCount
	local resultNumbre	= math.random(1, 11)
	local taunted	= ""
	if (x <= 9) then
		if (CurvyHud.state.inDungeon) then
			taunted	= CurvyHud.deadInDungeon[resultNumbre]
		else
			taunted	= CurvyHud.deadInWorld[resultNumbre]
		end	
	elseif (x == 10) then
		taunted = L.Repair
	elseif (x > 10 and x <= 19) then
		if (CurvyHud.state.inDungeon) then
			taunted	= CurvyHud.deadInDungeon[resultNumbre]
		else
			taunted	= CurvyHud.deadInWorld[resultNumbre]
		end		
	elseif (x == 20) then
		taunted = L.Repair
	elseif (x > 20) then
		if (CurvyHud.state.inDungeon) then
			taunted	= CurvyHud.deadInDungeon[resultNumbre]
		else
			taunted	= CurvyHud.deadInWorld[resultNumbre]
		end			
	end
	CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.Deathbegin..x..taunted)
end

function CurvyHud:DungeonInformationChat()

	local indexNum 	= GetUnitZoneIndex("player")
	--d(indexNum)
	local dungeon	= CurvyHud.zonesIndex[indexNum]
	local raids		= CurvyHud.zonesIndex[indexNum]
	local cfg 			= CurvyHud.config	
	if (CurvyHud.state.playerDead) then
		CurvyHud.state.playerDeadCount	= 1
		if (cfg.troll) then
			CurvyHud:DeadInformation()
		end
	else
		CurvyHud.state.playerDeadCount	= 0
--		CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.DeadCountRAZ)
	end
	local dungeonDiff = GetCurrentZoneDungeonDifficulty()
	local difficulty = 1
	if (dungeonDiff == DUNGEON_DIFFICULTY_VETERAN) then
		difficulty = 2
	end
	if (dungeon == "Dungeon" or raids == "Raid") then
		CurvyHud:InitializeChrono()
		CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.Dungeonbegin..CurvyHud.dungeonDiff[difficulty])
		if (CurvyHud.config.clepsydre.show) then
			CurvyHud:ChonoAutoMode(CurvyHud.config.clepsydre.automaticChrono)
		end
		CurvyHud:OnChatChronoMode()
	end
end

function CurvyHud.OnPlayerActivated()

	CurvyHud.ReloadFrames()
	CurvyHud.OnReticleTarget(131118)
	CurvyHud.location.activated = GetUnitZoneIndex("player")
	if (CurvyHud.location.activated ~= CurvyHud.location.init) then
		CurvyHud:DungeonInformationChat()
		CurvyHud.location.init = CurvyHud.location.activated
		CurvyHud.state.bossHere = false
	end
	CurvyHud:UpadteSightColor()
	CurvyHud:UpadteSightChatInformations()
end