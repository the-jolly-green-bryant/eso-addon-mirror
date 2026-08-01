local HarvensClock = {}

function HarvensClock:UpdateClock()
	local hours, minutes, sec
	if GetTST and type(GetTST) == "function" and self.sv.useTST then
		hours, minutes, sec = unpack(GetTST())
	else
		hours, minutes, sec = string.match(GetTimeString(), "([0-9][0-9]):([0-9][0-9]):([0-9][0-9])")
	end
	
	minutes = tonumber(minutes)
	sec = tonumber(sec)
	hours = tonumber(hours)

	hours = hours * self.hstep + self.hstep*minutes/60
	minutes = minutes * self.mstep + self.mstep*sec/60
	
	self.handm:SetTextureRotation(-(minutes), 0.5, 0.82)
	self.handm_light:SetTextureRotation(-(minutes), 0.5, 0.82)
	self.handh:SetTextureRotation(-(hours), 0.5, 0.7)
	self.handh_light:SetTextureRotation(-(hours), 0.5, 0.7)
end

function HarvensClock:HideInCombat(inCombat)
	self.base:SetHidden(inCombat)
	if not inCombat then
		self:UpdateClock()
	end
end

function HarvensClock:InitSavedVariable()
	if not HDC_Storage then
		HDC_Storage = {}
	end
	local unitName = zo_strformat("<<1>>", GetUnitName("player"))
	if not HDC_Storage[unitName] then
		HDC_Storage[unitName] = {}
	end
	
	return HDC_Storage[unitName]
end

function HarvensClock:Initialize(eventType, addonName)
	if addonName ~= "HarvensDwemerClock" then
		return
	end
	
	self.sv = self:InitSavedVariable()
	
	self.mstep = 2*math.pi/60
	self.hstep =  2*math.pi/12

	self.controls = {}

	self.base = WINDOW_MANAGER:CreateTopLevelWindow("HarvensClockBase")
	if self.sv.point then
		self.base:SetAnchor(self.sv.point, GuiRoot, self.sv.relPoint, self.sv.x, self.sv.y)
	else
		self.base:SetAnchor(CENTER)
	end
	if self.sv.useTST == nil then
		self.sv.useTST = false
	end
	
	self.base:SetClampedToScreen(true)
	self.base:SetClampedToScreenInsets(100, 100, -100, -100)
	self.base:SetHidden(false)
	self.base:SetResizeToFitDescendents(false)

	self.base.Scale = function(scale)
		for ctl,info in pairs(self.controls) do
			ctl:ClearAnchors()
			ctl:SetDimensions(info.width * scale, info.height * scale)
			ctl:SetAnchor(CENTER, self.base, CENTER, info.offsetX * scale, info.offsetY * scale)
		end
		self.base:SetDimensions(512 * scale, 512 * scale)
	end
  
	self.base:SetMouseEnabled(true)
	self.base:SetMovable(true)
	self.base:SetHidden(true)
	self.base:SetHandler("OnMouseWheel", function(control, delta)
		if delta > 0 then
			self.sv.scale = math.min(self.sv.scale + 0.05, 2)
		else
			self.sv.scale = math.max(0.20, self.sv.scale - 0.05)
		end
    self.base.Scale(self.sv.scale)
	end)
	if GetTST and type(GetTST) == "function" then
		self.base:SetHandler("OnMouseUp", function(control, button)
			if button ~= 2 then return end
			ClearMenu()
			if self.sv.useTST then
				AddMenuItem("Use Real Time Clock", function() self.sv.useTST = false end)
			else
				AddMenuItem("Use Tamriel Standard Time Clock", function() self.sv.useTST = true end)
			end
			ShowMenu(control)
		end)
	end
	self.base:SetHandler("OnMoveStop", function()
		_, self.sv.point, _, self.sv.relPoint, self.sv.x, self.sv.y = self.base:GetAnchor(0)
	end)
	
	local gear1 = WINDOW_MANAGER:CreateControl("HarvensClockGear1", self.base, CT_TEXTURE)
	gear1:SetTexture("HarvensDwemerClock/imgs/gear1.dds")
	gear1:SetDimensions(128, 128)
	self.controls[gear1] = { width=128, height=128, offsetX=-1.17, offsetY=-103.57 }
	
	local gear2 = WINDOW_MANAGER:CreateControl("HarvensClockGear2", self.base, CT_TEXTURE)
	gear2:SetTexture("HarvensDwemerClock/imgs/gear1.dds")
	gear2:SetDimensions(128, 128)
	gear2:SetTextureRotation(1.55, 0.5, 0.5)
	self.controls[gear2] = { width=128, height=128, offsetX=89.89, offsetY=-33.68 }
	
	local gear3 = WINDOW_MANAGER:CreateControl("HarvensClockGear3", self.base, CT_TEXTURE)
	gear3:SetTexture("HarvensDwemerClock/imgs/gear2.dds")
	self.controls[gear3] = { width=204.8, height=204.8, offsetX=-44, offsetY=31}

	local gear4 = WINDOW_MANAGER:CreateControl("HarvensClockGear4", self.base, CT_TEXTURE)
	gear4:SetTexture("HarvensDwemerClock/imgs/gear3.dds")
	self.controls[gear4] = { width=128, height=128, offsetX=68, offsetY=76 }
	
	local gear5 = WINDOW_MANAGER:CreateControl("HarvensClockGear5", self.base, CT_TEXTURE)
	gear5:SetTexture("HarvensDwemerClock/imgs/gear4.dds")
	self.controls[gear5] = { width=256, height=256, offsetX=0, offsetY=0 }

	local clockFrame = WINDOW_MANAGER:CreateControl("HarvensClockFrame", self.base, CT_TEXTURE)
	clockFrame:SetTexture("HarvensDwemerClock/imgs/frame.dds")
	self.controls[clockFrame] = { width=563.2, height=563.2, offsetX=0, offsetY=0 }
	
	local clockFace = WINDOW_MANAGER:CreateControl("HarvensClockFace", self.base, CT_TEXTURE)
	clockFace:SetTexture("HarvensDwemerClock/imgs/face.dds")
	self.controls[clockFace] = { width=512, height=512, offsetX=0, offsetY=0 }
	
	self.handm = WINDOW_MANAGER:CreateControl("HarvensClockHandM", self.base, CT_TEXTURE)
	self.handm:SetTexture("HarvensDwemerClock/imgs/handm.dds")
	self.controls[self.handm] = { width=54.4, height=217.6, offsetX=0, offsetY=-67 }

	self.handm_light = WINDOW_MANAGER:CreateControl("HarvensClockHandMLight", self.base, CT_TEXTURE)
	self.handm_light:SetTexture("HarvensDwemerClock/imgs/handm_light.dds")
	self.controls[self.handm_light] = { width=54.4, height=217.6, offsetX=0, offsetY=-67 }
	
	self.handh = WINDOW_MANAGER:CreateControl("HarvensClockHandH", self.base, CT_TEXTURE)
	self.handh:SetTexture("HarvensDwemerClock/imgs/handh.dds")
	self.controls[self.handh] = { width=64, height=256, offsetX=0, offsetY=-49}

	self.handh_light = WINDOW_MANAGER:CreateControl("HarvensClockHandHLight", self.base, CT_TEXTURE)
	self.handh_light:SetTexture("HarvensDwemerClock/imgs/handh_light.dds")
	self.controls[self.handh_light] = { width=64, height=256, offsetX=0, offsetY=-49 }
	
	local clockMiddle = WINDOW_MANAGER:CreateControl("HarvensClockMiddle", self.base, CT_TEXTURE)
	clockMiddle:SetTexture("HarvensDwemerClock/imgs/middle.dds")
	self.controls[clockMiddle] = { width=128, height=128, offsetX=0, offsetY=0}
	
	local gear1Rotate = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensClockGear1Rotate", gear1)
	gear1Rotate:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
	gear1Rotate:PlayFromStart(0)
	
	local gear2Rotate = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensClockGear1Rotate", gear2)
	gear2Rotate:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
	gear2Rotate:PlayFromEnd(0)
	
	local gear3Rotate = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensClockGear2Rotate", gear3)
	gear3Rotate:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
	gear3Rotate:PlayFromEnd(0)
	
	local gear4Rotate = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensClockGear5Rotate", gear4)
	gear4Rotate:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, LOOP_INDEFINITELY)
	gear4Rotate:PlayFromEnd(0)
	
	local gear5Rotate = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensClockGear3Rotate", gear5)
	gear5Rotate:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
	gear5Rotate:PlayFromEnd(0)
	
	local handMPulse = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensClockHandPulse", self.handm_light)
	handMPulse:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, LOOP_INDEFINITELY)
	handMPulse:PlayFromStart(0)

	local handHPulse = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensClockHandPulse", self.handh_light)
	handHPulse:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, LOOP_INDEFINITELY)
	handHPulse:PlayFromStart(0)	

	if not self.sv.scale then
		self.sv.scale = 1
	end

	EVENT_MANAGER:RegisterForUpdate("HarvensClockUpdate", 1000, function(...) HarvensClock:UpdateClock(...) end)

	self.base:SetHandler("OnEffectivelyShown", function()
		self.base.Scale(self.sv.scale)
	end)

	local fragment = ZO_SimpleSceneFragment:New(self.base)
	fragment:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			HarvensClock:UpdateClock()
		end
	end)
	local scene = SCENE_MANAGER:GetScene("hudui")
	scene:AddFragment(fragment)
	scene = SCENE_MANAGER:GetScene("hud")
	scene:AddFragment(fragment)

	self.base:SetHidden(false)
	
	EVENT_MANAGER:RegisterForEvent("HarvensDwemerClock", EVENT_PLAYER_COMBAT_STATE, function(_, incombat) HarvensClock:HideInCombat(incombat) end)
end

EVENT_MANAGER:RegisterForEvent("HarvensDwemerClock", EVENT_ADD_ON_LOADED, function(...) HarvensClock:Initialize(...) end)