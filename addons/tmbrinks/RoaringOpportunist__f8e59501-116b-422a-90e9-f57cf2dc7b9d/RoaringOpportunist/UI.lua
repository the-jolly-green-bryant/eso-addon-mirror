RoaringOpportunist = RoaringOpportunist or { }
local RO = RoaringOpportunist
local SM = SCENE_MANAGER
local LCA = LibCombatAlerts

function RO.setHudDisplay(inscene, hidden)
	if inscene then
		SM:GetScene('hud'):AddFragment(RO.UI.frag)
		SM:GetScene('hudui'):AddFragment(RO.UI.frag)
	else
		SM:GetScene('hud'):RemoveFragment(RO.UI.frag)
		SM:GetScene('hudui'):RemoveFragment(RO.UI.frag)
	end
	RO.UI.frame:SetHidden(hidden)
end

function RO.setupUI()
	RO.UI = { }
	RO.UI.frame = RoaringOpportunistFrame
	RO.UI.countdown1 = RoaringOpportunistFrameTime1
	RO.UI.countdown2 = RoaringOpportunistFrameTime2
	RO.UI.slayer1 = RoaringOpportunistFrameSlayerTime1
	RO.UI.slayer2 = RoaringOpportunistFrameSlayerTime2
	RO.UI.frag = ZO_HUDFadeSceneFragment:New(RO.UI.frame)

local handler = LCA.MoveableControl:New(RO.UI.frame)
	handler:UpdatePosition(RoaringOpportunist.savedVars.pos)
	handler:RegisterCallback("RoaringOpportunist", LCA.EVENT_CONTROL_MOVE_STOP, function(newPos)
		RoaringOpportunist.savedVars.pos = newPos
	end)
	RoaringOpportunist.posHandler = handler
	
	--local x, y = RO.savedVars.offsetX, RO.savedVars.offsetY
	--RO.UI.frame:ClearAnchors()
	--RO.UI.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)

	if not RO.savedVars.showProcTime then
		RO.UI.slayer1:SetHidden(true)
		RO.UI.slayer2:SetHidden(true)
	end
	RO.UI.countdown1:SetColor(unpack(RO.savedVars.colors.UP))
	RO.UI.slayer1:SetColor(unpack(RO.savedVars.colors.SLAYERTIMER))
	RO.UI.countdown2:SetColor(unpack(RO.savedVars.colors.UP))
	RO.UI.slayer2:SetColor(unpack(RO.savedVars.colors.SLAYERTIMER))
	RO.UI.frame:SetScale(RO.savedVars.scale)

	RO.setHudDisplay(true, false)
end

--[[function RO.savePos()
	RO.savedVars.offsetX = RO.UI.frame:GetLeft()
	RO.savedVars.offsetY = RO.UI.frame:GetTop()
end]]

