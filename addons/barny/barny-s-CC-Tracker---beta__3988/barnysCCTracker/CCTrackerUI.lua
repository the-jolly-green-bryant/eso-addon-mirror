local WM = WINDOW_MANAGER
CCTracker = CCTracker or {}

	--------------------------
	---- Build CC Tracker ----
	--------------------------

function CCTracker:BuildUI()
	
	local indicator = {}
	
	local function GetIndicator(name, iconPath)
		local size = self.SV.UI.sizes.oneForAll and self.SV.UI.sizes.size or self.SV.UI.sizes[name]
		local timerBarY = self.SV.UI.sizes.oneForAll and self.SV.UI.sizes.size/3 or self.SV.UI.sizes[name]/3
		
		local tlw = WM:CreateTopLevelWindow(self.name..name.."Frame")
		tlw:SetDimensionConstraints(10, 10, 200, 200)
		tlw:SetDimensions(size, size)
		tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SV.UI.xOffsets[name], self.SV.UI.yOffsets[name])
		tlw:SetDrawTier(DT_HIGH)
		tlw:SetClampedToScreen(self.SV.settings.unlocked)
		tlw:SetResizeHandleSize(2)
		tlw:SetHandler("OnMoveStop", function(...)
			self.SV.UI.xOffsets[name] = tlw:GetLeft()
			self.SV.UI.yOffsets[name] = tlw:GetTop()
		end)
		tlw:SetHandler("OnResizeStop", function(...)
			if not self.SV.UI.sizes.oneForAll then
				if tlw:GetHeight() == self.SV.UI.sizes.size and tlw:GetWidth() ~= self.SV.UI.sizes.size then
					self.SV.UI.sizes[name] = tlw:GetWidth()
					-- tlw:SetHeight(self.SV.UI.sizes[name])
					self.UI.ApplySize(name)
				elseif tlw:GetHeight() ~= self.SV.UI.sizes.size and tlw:GetWidth() == self.SV.UI.sizes.size then
					self.SV.UI.sizes[name] = tlw:GetHeight()
					-- tlw:SetWidth(self.SV.UI.sizes[name])
					self.UI.ApplySize(name)
				elseif tlw:GetHeight() ~= self.SV.UI.sizes.size and tlw:GetWidth() ~= self.SV.UI.sizes.size then
					self.SV.UI.sizes[name] = tlw:GetHeight()
					-- tlw:SetWidth(self.SV.UI.sizes[name])
					self.UI.ApplySize(name)
				end
			else
				self.UI.indicator[name].controls.tlw:SetDimensions(self.SV.UI.sizes.size, self.SV.UI.sizes.size)
			end
		end)
		local fragment = ZO_HUDFadeSceneFragment:New(tlw)
		
		local icon = WM:CreateControl(self.name..name.."Icon", tlw, CT_TEXTURE)
		icon:ClearAnchors()
		icon:SetAnchorFill()
		icon:SetTexture(iconPath)
		icon:SetHidden(true)
		
		local tlwShadow = WM:CreateControl(self.name..name.."FrameBG", tlw, CT_BACKDROP)
		tlwShadow:SetAnchorFill()
		tlwShadow:SetDimensions(size, size)
		tlwShadow:SetEdgeColor(0,0,0,0)
		tlwShadow:SetEdgeTexture(nil,1,1,0,0)
		tlwShadow:SetCenterColor(0.5,0.5,0.5,0.75)
		tlwShadow:SetDrawTier(DT_HIGH)
		tlwShadow:SetHidden(true)
		
		local tlwLabel = WM:CreateControl(self.name..name.."Label", tlw, CT_LABEL)
		tlwLabel:SetText(name)
		tlwLabel:SetAnchor(CENTER, tlw, CENTER, 0, 0)
		tlwLabel:SetHidden(true)
		tlwLabel:SetFont("$(MEDIUM_FONT)|"..(self.SV.UI.sizes[name]/5).."|outline")
		
		local frame = WM:CreateControl(self.name..name.."IconFrame", tlw, CT_TEXTURE)
		frame:ClearAnchors()
		frame:SetAnchorFill()
		frame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
		frame:SetHidden(true)
		
		local timer = WM:CreateControl(self.name..name.."Timer", tlw, CT_LABEL)
		timer:SetDrawTier(DT_HIGH)
		timer:SetColor(unpack(self.SV.UI.timers.oneForAll and self.SV.UI.timers.timerColor or self.SV.UI.timers[name].timerColor))
		timer:SetAlpha(1)
		timer:SetFont("$(MEDIUM_FONT)|"..(size*0.6).."|outline")
		timer:SetHidden(true)
		
		local timerBarBackdrop = WINDOW_MANAGER:CreateControl(self.name..name.."TimerBarBackdrop", tlw, CT_BACKDROP)
		timerBarBackdrop:SetDrawTier(DT_HIGH)
		timerBarBackdrop:SetCenterColor(0.06, 0.06, 0.06, 0.7)
		timerBarBackdrop:SetEdgeTexture("/esoui/art/miscellaneous/borderedinsettransparent_edgefile.dds", 128, 16, size/10)
		timerBarBackdrop:SetDimensions(size, size/3)
		timerBarBackdrop:SetHidden(true)
		
		local timerBar = WINDOW_MANAGER:CreateControl(self.name..name.."TimerBar", timerBarBackdrop, CT_STATUSBAR)
		timerBar:SetDrawTier(DT_HIGH)
		timerBar:SetColor(unpack(self.SV.UI.timers.oneForAll and self.SV.UI.timers.timerBarColor or self.SV.UI.timers[name].timerBarColor))
		timerBar:SetDimensions(0.965*size, timerBarY-0.035*size)
		timerBar:SetHidden(true)
		
		local timerBarGloss = WINDOW_MANAGER:CreateControl(self.name..name.."TimerBarGloss", timerBarBackdrop, CT_TEXTURE)
		timerBarGloss:SetDrawTier(DT_HIGH)
		timerBarGloss:SetAlpha(0.9)
		timerBarGloss:SetTexture("/esoui/art/unitattributevisualizer/gamepad/gp_attributebar_dynamic_fill_gloss.dds")
		timerBarGloss:SetTextureCoords(0, 1, 0.5, 0.36)
		timerBarGloss:SetHidden(true)
		timerBarGloss:SetAnchorFill(timerBar)
		
		local controls = {
			tlw = tlw,
			tlwShadow = tlwShadow,
			tlwLabel = tlwLabel,
			frame = frame,
			icon = icon,
			fragment = fragment,
			timerBar = timerBar,
			timerBarBackdrop = timerBarBackdrop,
			timerBarGloss = timerBarGloss,
			timer = timer,
		}
		
		return {
			controls = controls,
		}
	end
	
	for _, entry in pairs(self.ccVariables) do
		indicator[entry.name] = GetIndicator(entry.name, entry.icon)
		-- indicator[entry.name].tracker = ZO_HUDFadeSceneFragment:New(tlw)
	end
	
	local function CreateLiveCCWindow()
		local tlw = WM:CreateTopLevelWindow(self.name.."LiveCCFrame")
		tlw:SetDimensionConstraints(10, 10, 800, 400)
		tlw:SetDimensions(self.SV.UI.debugWindow.width, self.SV.UI.debugWindow.height)
		tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SV.UI.debugWindow.xOffset, self.SV.UI.debugWindow.yOffset)
		tlw:SetDrawTier(DT_HIGH)
		tlw:SetClampedToScreen(false)
		tlw:SetResizeHandleSize(2)
		tlw:SetMouseEnabled(true)
		tlw:SetMovable(true)
		tlw:SetHandler("OnMoveStop", function(...)
			self.SV.UI.debugWindow.xOffset = tlw:GetLeft()
			self.SV.UI.debugWindow.yOffset = tlw:GetTop()
		end)
		tlw:SetHandler("OnResizeStop", function(...)
			self.SV.UI.debugWindow.width = tlw:GetWidth()
			self.SV.UI.debugWindow.height = tlw:GetHeight()
		end)
		local fragment = ZO_HUDFadeSceneFragment:New(tlw)
		
		local tlwShadow = WM:CreateControl(self.name.."LiveCCBG", tlw, CT_BACKDROP)
		tlwShadow:SetAnchorFill()
		tlwShadow:SetDimensions(self.SV.UI.debugWindow.width, self.SV.UI.debugWindow.height)
		tlwShadow:SetEdgeColor(0,0,0,1)
		tlwShadow:SetEdgeTexture(nil,1,1,0,0)
		tlwShadow:SetCenterColor(0.25,0.25,0.25,0.75)
		tlwShadow:SetDrawTier(DT_HIGH)
		tlwShadow:SetHidden(true)
				
		local tlwLabel = WM:CreateControl(self.name.."LiveCCLabel", tlw, CT_LABEL)
		tlwLabel:SetText("")
		tlwLabel:SetAnchor(TOPLEFT, tlw, TOPLEFT, 4, 2)
		tlwLabel:SetHidden(true)
		tlwLabel:SetFont("$(MEDIUM_FONT)|17|outline")
		tlwLabel:SetDrawTier(DT_HIGH)
		
		local controls = {
			fragment = fragment,
			tlw = tlw,
			tlwShadow = tlwShadow,
			tlwLabel = tlwLabel,
		}
		
		return {
			controls = controls,
		}
	end
	
	local liveCCWindow = CreateLiveCCWindow()
	
	local function HideLiveCCWindow(value)
		liveCCWindow.controls.tlwShadow:SetHidden(not value)
		liveCCWindow.controls.tlwLabel:SetHidden(not value)
	end
	 
	local function FadeScenes(value)
		if value == "UI" then
			for _, entry in pairs(CCTracker.ccVariables) do
				SCENE_MANAGER:GetScene("hud"):AddFragment(CCTracker.UI.indicator[entry.name].controls.fragment)
				SCENE_MANAGER:GetScene("hudui"):AddFragment(CCTracker.UI.indicator[entry.name].controls.fragment)
			end
			SCENE_MANAGER:GetScene("hud"):AddFragment(CCTracker.UI.liveCCWindow.controls.fragment)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(CCTracker.UI.liveCCWindow.controls.fragment)
		elseif value == "Unlocked" then
			for _, entry in pairs(CCTracker.ccVariables) do
				SCENE_MANAGER:GetScene("gameMenuInGame"):AddFragment(CCTracker.UI.indicator[entry.name].controls.fragment)
			end
		elseif value == "Locked" then
			for _, entry in pairs(CCTracker.ccVariables) do
				SCENE_MANAGER:GetScene("gameMenuInGame"):RemoveFragment(CCTracker.UI.indicator[entry.name].controls.fragment)
			end
		end
	end
		
	-- for i=1,10 do
		-- indicator[i] = GetIndicator(i)
	-- end
	
	local function SetUnlocked(value)
		for _, entry in pairs(self.ccVariables) do
			if value and entry.tracked then
				indicator[entry.name].controls.tlw:SetDrawTier(DT_HIGH)
				indicator[entry.name].controls.tlw:SetMouseEnabled(true)
				indicator[entry.name].controls.tlw:SetMovable(true)
				indicator[entry.name].controls.tlw:SetHidden(false)
				indicator[entry.name].controls.tlwShadow:SetHidden(false)
				indicator[entry.name].controls.tlwLabel:SetHidden(false)
				indicator[entry.name].controls.icon:SetHidden(false)
				indicator[entry.name].controls.timer:SetHidden(false)
				indicator[entry.name].controls.timer:SetText("9.8s")
				indicator[entry.name].controls.timerBar:SetHidden(false)
				indicator[entry.name].controls.timerBarBackdrop:SetHidden(false)
				indicator[entry.name].controls.timerBarGloss:SetHidden(false)
				indicator[entry.name].controls.tlw:SetClampedToScreen(false)
			elseif not value or not entry.tracked then 
				indicator[entry.name].controls.tlw:SetDrawTier(DT_LOW)
				indicator[entry.name].controls.tlw:SetMouseEnabled(false)
				indicator[entry.name].controls.tlw:SetMovable(false)
				indicator[entry.name].controls.tlw:SetHidden(true)
				indicator[entry.name].controls.tlwShadow:SetHidden(true)
				indicator[entry.name].controls.tlwLabel:SetHidden(true)
				indicator[entry.name].controls.icon:SetHidden(true)
				indicator[entry.name].controls.timer:SetHidden(true)
				indicator[entry.name].controls.timer:SetText("")
				indicator[entry.name].controls.timerBar:SetHidden(true)
				indicator[entry.name].controls.timerBarBackdrop:SetHidden(true)
				indicator[entry.name].controls.timerBarGloss:SetHidden(true)
				indicator[entry.name].controls.tlw:SetClampedToScreen(true)
			end
		end
		if value then FadeScenes("Unlocked") else FadeScenes("Locked") end
		FadeScenes("UI")
		self.SV.settings.unlocked = value
	end
	-- indicator.SetUnlocked = SetUnlocked
	
	local function ApplyTimerAnchors(name)
		local size = self.SV.UI.sizes.oneForAll and self.SV.UI.sizes.size or self.SV.UI.sizes[name]
		local timerBarY = self.SV.UI.sizes.oneForAll and self.SV.UI.sizes.size/3 or self.SV.UI.sizes[name]/3
		indicator[name].controls.timer:ClearAnchors()
		indicator[name].controls.timerBar:ClearAnchors()
		indicator[name].controls.timerBarBackdrop:ClearAnchors()
		indicator[name].controls.timerBarBackdrop:SetAnchor(TOP, indicator[name].controls.tlw, BOTTOM, 0, size*0.05)
		if self.SV.UI.timers.oneForAll then
			if self.SV.UI.timers.timerAnchor == "ICON" or not self.SV.UI.timers.showTimerBar then
				indicator[name].controls.timer:SetFont("$(MEDIUM_FONT)|"..(size*0.6).."|outline")
				indicator[name].controls.timer:SetAnchor(CENTER, indicator[name].controls.tlw, CENTER, 0, 0)
			else
				indicator[name].controls.timer:SetFont("$(MEDIUM_FONT)|"..(size*0.25).."|outline")
				indicator[name].controls.timer:SetAnchor(CENTER, indicator[name].controls.timerBar, CENTER, 0, 0)
			end
			if self.SV.UI.timers.timerBarOrientation == "LEFT" then
				indicator[name].controls.timerBar:SetAnchor(LEFT, indicator[name].controls.timerBarBackdrop, LEFT, size*0.015, 0)
			else
				indicator[name].controls.timerBar:SetAnchor(RIGHT, indicator[name].controls.timerBarBackdrop, RIGHT, -size*0.015, 0)
			end
		else
			if self.SV.UI.timers[name].timerAnchor == "ICON" or not self.SV.UI.timers[name].showTimerBar then
				indicator[name].controls.timer:SetFont("$(MEDIUM_FONT)|"..(size*0.6).."|outline")
				indicator[name].controls.timer:SetAnchor(CENTER, indicator[name].controls.tlw, CENTER, 0, 0)
			else
				indicator[name].controls.timer:SetFont("$(MEDIUM_FONT)|"..(size*0.25).."|outline")
				indicator[name].controls.timer:SetAnchor(CENTER, indicator[name].controls.timerBar, CENTER, 0, 0)
			end
			if self.SV.UI.timers[name].timerBarOrientation == "LEFT" then
				indicator[name].controls.timerBar:SetAnchor(LEFT, indicator[name].controls.timerBarBackdrop, LEFT, size*0.015, 0)
			else
				indicator[name].controls.timerBar:SetAnchor(RIGHT, indicator[name].controls.timerBarBackdrop, RIGHT, -size*0.015, 0)
			end
		end
	end
	
	for _, entry in pairs(self.ccVariables) do
		ApplyTimerAnchors(entry.name)
	end
	
	local function ApplySize(name)
		local size = self.SV.UI.sizes.oneForAll and self.SV.UI.sizes.size or self.SV.UI.sizes[name]
		local timerBarY = self.SV.UI.sizes.oneForAll and self.SV.UI.sizes.size/3 or self.SV.UI.sizes[name]/3
		indicator[name].controls.tlw:SetDimensions(size, size)
		indicator[name].controls.tlwShadow:SetDimensions(size, size)
		indicator[name].controls.frame:SetDimensions(size, size)
		indicator[name].controls.icon:SetDimensions(size, size)
		indicator[name].controls.tlwLabel:SetFont("$(MEDIUM_FONT)|"..(size/5).."|outline")
		indicator[name].controls.timerBarBackdrop:SetDimensions(size, size/3)
		indicator[name].controls.timerBarBackdrop:SetEdgeTexture("/esoui/art/miscellaneous/borderedinsettransparent_edgefile.dds", 128, 16, size/10)
		indicator[name].controls.timerBar:SetDimensions(0.965*size, timerBarY-0.035*size)
		ApplyTimerAnchors(name)
	end
	-- indicator.ApplySize = ApplySize

	local function ApplyIcons()
		for _, entry in pairs(self.ccVariables) do
			entry.active = false
			self.UI.indicator[entry.name].controls.frame:SetHidden(true)
			self.UI.indicator[entry.name].controls.icon:SetHidden(true)
			self.UI.indicator[entry.name].controls.timerBarBackdrop:SetHidden(true)
			self.UI.indicator[entry.name].controls.timer:SetHidden(true)
		end
		-- self:PrintDebug("enabled", "CC icons hidden")
		
		for _, entry in ipairs(self.ccActive) do
			self.ccVariables[entry.type].active = true
			self.UI.indicator[self.ccVariables[entry.type].name].controls.frame:SetHidden(false)
			self.UI.indicator[self.ccVariables[entry.type].name].controls.icon:SetHidden(false)
			self.UI.indicator[self.ccVariables[entry.type].name].controls.timerBarBackdrop:SetHidden(false)
			self.UI.indicator[self.ccVariables[entry.type].name].controls.timer:SetHidden(false)
		end
		-- self:PrintDebug("enabled", "CC icons are shown")
	end
	
	local function ApplyAlpha()
		for _, entry in pairs(self.ccVariables) do
			indicator[entry.name].controls.icon:SetAlpha(self.SV.UI.alpha.oneForAll and self.SV.UI.alpha.alpha or self.SV.UI.alpha[entry.name]/100)
			indicator[entry.name].controls.frame:SetAlpha(self.SV.UI.alpha.oneForAll and self.SV.UI.alpha.alpha or self.SV.UI.alpha[entry.name]/100)
		end
	end
	
	SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, newState)
		if scene:GetName() == "gameMenuInGame" and newState == "hiding" and self.SV.settings.sample then
			self.SV.settings.sample = false
			self.UI.FadeScenes("Locked")
			self.UI.indicator.Stun.controls.tlw:ClearAnchors()
			self.UI.indicator.Stun.controls.tlw:SetHidden(true)
			self.UI.indicator.Stun.controls.icon:SetHidden(true)
			self.UI.indicator.Stun.controls.frame:SetHidden(true)
			self.UI.indicator.Stun.controls.tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SV.UI.xOffsets.Stun, self.SV.UI.yOffsets.Stun)
		end
	end)
		
	return {
	indicator = indicator,
	ApplyIcons = ApplyIcons,
	ApplySize = ApplySize,
	SetUnlocked = SetUnlocked,
	FadeScenes = FadeScenes,
	ApplyAlpha = ApplyAlpha,
	ApplyTimerAnchors = ApplyTimerAnchors,
	liveCCWindow = liveCCWindow,
	HideLiveCCWindow = HideLiveCCWindow,
	}
end