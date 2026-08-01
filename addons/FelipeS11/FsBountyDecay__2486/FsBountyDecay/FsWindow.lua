--
-- This file handles the window to display.
--
-- If the global variable was created, continue with the execution
if not FsBountyDecay.fsAddonCreated then return end

local wm = GetWindowManager()

function FsBountyDecay_UpdateBountyDecays()
	local secsBounty = GetSecondsUntilBountyDecaysToZero()
	FsBountyDecay_Timer.Bounty:SetHidden(secsBounty <= 0)
	if(FsBountyDecay.settings.isClock)then
		FsBountyDecay_Timer.Bounty:SetText(GetString(SI_FSBOUNTDECAY_WINDOW_BOUNTY) .. FsBountyDecay.Utils.SecondsToStr(secsBounty))
	else
		FsBountyDecay_Timer.Bounty:SetText(GetString(SI_FSBOUNTDECAY_WINDOW_BOUNTY) .. secsBounty)
	end
	
	local secsHeat = GetSecondsUntilHeatDecaysToZero()
	FsBountyDecay_Timer.Heat:SetHidden(secsHeat <= 0)
	if(FsBountyDecay.settings.isClock)then
		FsBountyDecay_Timer.Heat:SetText(GetString(SI_FSBOUNTDECAY_WINDOW_HEAT) .. FsBountyDecay.Utils.SecondsToStr(secsHeat))
	else
		FsBountyDecay_Timer.Heat:SetText(GetString(SI_FSBOUNTDECAY_WINDOW_HEAT) .. secsHeat)
	end
	
	local _hidden = FsBountyDecay_Timer.Bounty:IsHidden() and FsBountyDecay_Timer.Heat:IsHidden();
	FsBountyDecay.Timer.header:SetHidden(_hidden)
	FsBountyDecay.Timer.lineH:SetHidden(_hidden)
	FsBountyDecay_Timer.lineB:SetHidden(_hidden)
	FsBountyDecay_Timer.lineB1:SetHidden(secsHeat <= 0)
	if((secsBounty + secsHeat > 0) and (not ZO_CompassFrame:IsHidden()))then
		zo_callLater(FsBountyDecay_UpdateBountyDecays, 1000)
	end
end

--
-- This function will create the window to display
--
local function FsBountyDecay_MakeWindow()

	FsBountyDecay.Timer = wm:CreateTopLevelWindow(FsBountyDecay.name .. '_Timer')
	
    local FsBountyDecay_Timer = FsBountyDecay.Timer
	FsBountyDecay_Timer:SetAnchor(FsBountyDecay.settings.point, GuiRoot, FsBountyDecay.settings.relPoint, FsBountyDecay.settings.x, FsBountyDecay.settings.y)
	FsBountyDecay_Timer:SetMovable(true)
	FsBountyDecay_Timer:SetMouseEnabled(true)
	FsBountyDecay_Timer:SetResizeToFitDescendents(true)
	FsBountyDecay_Timer:SetHandler("OnMoveStop", function()
		local isValid, point, relTo, relPoint, offsetX, offsetY = FsBountyDecay_Timer:GetAnchor()
		
		if(FsBountyDecay.isDebug)then
			FsBountyDecay.Utils.PrintMsgColorize('debug anchor>>>' .. tostring(point) .. ' - ' .. tostring(relTo) .. ' - ' .. tostring(relPoint) .. ' - ' .. tostring(offsetX) .. ' - ' .. tostring(offsetY))
		end
		if(isValid)then
			FsBountyDecay.settings.x = offsetX
			FsBountyDecay.settings.y = offsetY
			FsBountyDecay.settings.point = point
			FsBountyDecay.settings.relPoint = relPoint
		end
	end)
	
	FsBountyDecay_Timer.bg = wm:CreateControl(FsBountyDecay.name .. "_TimerBackground", FsBountyDecay_Timer, CT_BACKDROP)
	FsBountyDecay_Timer.bg:SetAnchorFill(FsBountyDecay_Timer)
	FsBountyDecay_Timer.bg:SetCenterTexture('EsoUI\\Art\\chatwindow\\chat_bg_center.dds')
	FsBountyDecay_Timer.bg:SetEdgeTexture('EsoUI\\Art\\ChatWindow\\chat_bg_edge.dds', 4, 4, 0, 0)
	FsBountyDecay_Timer.bg:SetExcludeFromResizeToFitExtents(true)
	FsBountyDecay_Timer.bg:SetDrawLayer(DL_BACKGROUND)
	
	-- give it a header
	FsBountyDecay_Timer.header = wm:CreateControl(FsBountyDecay.name .. "_TimerHeader", FsBountyDecay_Timer, CT_LABEL)
	FsBountyDecay_Timer.header:SetAnchor(TOP, FsBountyDecay_Timer, TOP, 0, 5)
	FsBountyDecay_Timer.header:SetFont("EsoUi/Common/Fonts/Univers67.otf|18|soft-shadow-thin")
	FsBountyDecay_Timer.header:SetColor(.9, .9, .7, 1)
	FsBountyDecay_Timer.header:SetStyleColor(0, 0, 0, 1)
	FsBountyDecay_Timer.header:SetText(GetString(SI_FSBOUNTDECAY_WINDOW_HEADER))
	
	-- Line to divide the header and the rest
	FsBountyDecay_Timer.lineH = wm:CreateControl(FsBountyDecay.name .. "_TimerLineH", FsBountyDecay_Timer, CT_LINE)
	FsBountyDecay_Timer.lineH:SetTexture("EsoUI/art/miscellaneous/wavy_line.dds")
	FsBountyDecay_Timer.lineH:SetAnchor(TOPLEFT, FsBountyDecay_Timer.header, BOTTOMLEFT, 0, 5)
	FsBountyDecay_Timer.lineH:SetAnchor(BOTTOMRIGHT, FsBountyDecay_Timer.header, BOTTOMRIGHT, 0, 5)
	FsBountyDecay_Timer.lineH:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	
	
	FsBountyDecay_Timer.Bounty = wm:CreateControl(FsBountyDecay.name .. "_TimerBountyTitle", FsBountyDecay_Timer, CT_LABEL)
	FsBountyDecay_Timer.Bounty:SetAnchor(TOP, FsBountyDecay_Timer.lineH, TOP, 0, 5)
	FsBountyDecay_Timer.Bounty:SetFont("EsoUi/Common/Fonts/Univers67.otf|18|soft-shadow-thin")
	FsBountyDecay_Timer.Bounty:SetColor(.9, .9, .7, 1)
	FsBountyDecay_Timer.Bounty:SetStyleColor(0, 0, 0, 1)
	FsBountyDecay_Timer.Bounty:SetText(GetString(SI_FSBOUNTDECAY_WINDOW_BOUNTY))
	
	FsBountyDecay_Timer.lineB = wm:CreateControl(FsBountyDecay.name .. "_LineB", FsBountyDecay_Timer, CT_LINE)
	FsBountyDecay_Timer.lineB:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
	FsBountyDecay_Timer.lineB:SetAnchor(BOTTOM, FsBountyDecay_Timer.Bounty, BOTTOM, 0, 5)
	FsBountyDecay_Timer.lineB:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	
	FsBountyDecay_Timer.Heat = wm:CreateControl(FsBountyDecay.name .. "_TimerHeatTitle", FsBountyDecay_Timer, CT_LABEL)
	FsBountyDecay_Timer.Heat:SetAnchor(BOTTOM, FsBountyDecay_Timer.lineB, BOTTOM, 0, 15)
	FsBountyDecay_Timer.Heat:SetFont("EsoUi/Common/Fonts/Univers67.otf|18|soft-shadow-thin")
	FsBountyDecay_Timer.Heat:SetColor(.9, .9, .7, 1)
	FsBountyDecay_Timer.Heat:SetStyleColor(0, 0, 0, 1)
	FsBountyDecay_Timer.Heat:SetText(GetString(SI_FSBOUNTDECAY_WINDOW_HEAT))
	
	FsBountyDecay_Timer.lineB1 = wm:CreateControl(FsBountyDecay.name .. "_LineB1", FsBountyDecay_Timer, CT_LINE)
	FsBountyDecay_Timer.lineB1:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
	FsBountyDecay_Timer.lineB1:SetAnchor(BOTTOMRIGHT, FsBountyDecay_Timer.Heat, BOTTOMLEFT, 0, 5)
	FsBountyDecay_Timer.lineB1:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	
	-- hide our window when the compass frame gets hidden, if it's not hidden already
	if ZO_CompassFrame:IsHandlerSet("OnShow") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnShow")
		ZO_CompassFrame:SetHandler("OnShow", function(...) oldHandler(...) FsBountyDecay.Timer:SetHidden(false) FsBountyDecay_UpdateBountyDecays() end)
	else
		ZO_CompassFrame:SetHandler("OnShow", function(...) FsBountyDecay.Timer:SetHidden(false) FsBountyDecay_UpdateBountyDecays() end)
	end
	if ZO_CompassFrame:IsHandlerSet("OnHide") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnHide")
		ZO_CompassFrame:SetHandler("OnHide", function(...) oldHandler(...) FsBountyDecay.Timer:SetHidden(true) end)
	else
		ZO_CompassFrame:SetHandler("OnHide", function(...) FsBountyDecay.Timer:SetHidden(true) end)
	end
	FsBountyDecay_UpdateBountyDecays()
end

--
-- RefreshWindow() is a callback for EVENT_ZONE_CHANGED. 
-- It populates the Timer with a window to show bounty/heat
--
function FsBountyDecay.RefreshWindow()
	if FsBountyDecay.Timer == nil then FsBountyDecay_MakeWindow() end
end
