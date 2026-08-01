local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateLatency()
	local WM = GetWindowManager()
	if RAEIH_Latency == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.LatencyX
		local mY = RAEIH.SavedVars.LatencyY
		local mW = RAEIH.SavedVars.LatencyIconW + 10
		local mH = RAEIH.SavedVars.LatencyIconH
		local iX = RAEIH.SavedVars.LatencyIconX
		local iY = RAEIH.SavedVars.LatencyIconY
		local iW = RAEIH.SavedVars.LatencyIconW
		local iH = RAEIH.SavedVars.LatencyIconH
		local bA = RAEIH.SavedVars.LatencyBA
		-- Main Placeholder
		RAEIH_Latency = WM:CreateTopLevelWindow("RAEIH_Latency")
		RAEIH_Latency:SetClampedToScreen(true)
		RAEIH_Latency:SetDrawLevel(1)
		RAEIH_Latency:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Latency:SetMouseEnabled(true)
		RAEIH_Latency:SetMovable(not RAEIH.SavedVars.LockLatency)
		RAEIH_Latency:SetHandler("OnReceiveDrag", RAEIH.StartMovingLatency)
		RAEIH_Latency:SetHandler("OnMouseUp", RAEIH.StopMovingLatency)
		RAEIH_Latency:SetHidden(not RAEIH.SavedVars.ShowLatency)
		-- Icon
		RAEIH_Latency_Icon = WM:CreateControl("RAEIH_Latency_Icon", RAEIH_Latency, CT_TEXTURE)
		RAEIH_Latency_Icon:SetTexture(RAEIH.Icons.Latency)
		RAEIH_Latency_Icon:SetDimensions(iW, iH)
		RAEIH_Latency_Icon:SetSimpleAnchor(RAEIH_Latency, iX, iY)
		-- String
		RAEIH_Latency_String = WM:CreateControl("RAEIH_Latency_String", RAEIH_Latency, CT_LABEL)
		RAEIH_Latency_String:SetSimpleAnchor(RAEIH_Latency, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Latency_String:SetHorizontalAlignment(CENTER)
		RAEIH_Latency_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Latency_Backdrop = WM:CreateControl("RAEIH_Latency_Backdrop", RAEIH_Latency, CT_BACKDROP)
		RAEIH_Latency_Backdrop:SetAnchorFill(RAEIH_Latency)
		RAEIH_Latency_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Latency_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetLatency()

	local clrDft = "|c" .. RAEIH.SavedVars.LatencyDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.LatencyAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.LatencyWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.LatencyNormalColour

	local Latency = GetLatency()

	if Latency >= 300 then
		clr = clrA
	elseif Latency <= 150 then
		clr = clrN
	else
		clr = clrW
	end

	if RAEIH.SavedVars.TSFormat == "Point (.)" then
		RAEIH.LatencyText = clr .. string.gsub(tostring(Latency), "%.", ",") .. "ms"
	else
		RAEIH.LatencyText = clr .. tostring(Latency) .. "ms"
	end
	RAEIH_Latency_String:SetText(RAEIH.LatencyText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatLatency()

	local font = LMP:Fetch('font', RAEIH.SavedVars.LatencyFont)
	local size = RAEIH.SavedVars.LatencyFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.LatencyFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Latency_String:SetFont(fontFormat)

end

function RAEIH.OrganizeLatency()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.LatencyX
	local mY = RAEIH.SavedVars.LatencyY
	local mW = RAEIH.SavedVars.LatencyIconW + RAEIH_Latency_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.LatencyIconH
	local iX = RAEIH.SavedVars.LatencyIconX
	local iY = RAEIH.SavedVars.LatencyIconY
	local iW = RAEIH.SavedVars.LatencyIconW
	local iH = RAEIH.SavedVars.LatencyIconH
	local bA = RAEIH.SavedVars.LatencyBA
	-- Update General Dimensions
	RAEIH_Latency:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Latency_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Latency_Icon:ClearAnchors()
	RAEIH_Latency_Icon:SetSimpleAnchor(RAEIH_Latency, iX, iY)
	-- Update String Anchor
	RAEIH_Latency_String:ClearAnchors()
	RAEIH_Latency_String:SetSimpleAnchor(RAEIH_Latency, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Latency_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingLatency()
	RAEIH_Latency:StartMoving()
end

function RAEIH.StopMovingLatency()
	RAEIH_Latency:StopMovingOrResizing()
	RAEIH.SavedVars.LatencyX = RAEIH_Latency:GetLeft()
	RAEIH.SavedVars.LatencyY = RAEIH_Latency:GetTop()
end