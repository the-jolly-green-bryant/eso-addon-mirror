local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateTime()
	local WM = GetWindowManager()
	if RAEIH_Time == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.TimeX
		local mY = RAEIH.SavedVars.TimeY
		local mW = RAEIH.SavedVars.TimeIconW + 10
		local mH = RAEIH.SavedVars.TimeIconH
		local iX = RAEIH.SavedVars.TimeIconX
		local iY = RAEIH.SavedVars.TimeIconY
		local iW = RAEIH.SavedVars.TimeIconW
		local iH = RAEIH.SavedVars.TimeIconH
		local bA = RAEIH.SavedVars.TimeBA
		-- Main Placeholder
		RAEIH_Time = WM:CreateTopLevelWindow("RAEIH_Time")
		RAEIH_Time:SetClampedToScreen(true)
		RAEIH_Time:SetDrawLevel(1)
		RAEIH_Time:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Time:SetMouseEnabled(true)
		RAEIH_Time:SetMovable(not RAEIH.SavedVars.LockTime)
		RAEIH_Time:SetHandler("OnReceiveDrag", RAEIH.StartMovingTime)
		RAEIH_Time:SetHandler("OnMouseUp", RAEIH.StopMovingTime)
		RAEIH_Time:SetHidden(not RAEIH.SavedVars.ShowTime)
		-- Icon
		RAEIH_Time_Icon = WM:CreateControl("RAEIH_Time_Icon", RAEIH_Time, CT_TEXTURE)
		RAEIH_Time_Icon:SetTexture(RAEIH.Icons.Time)
		RAEIH_Time_Icon:SetDimensions(iW, iH)
		RAEIH_Time_Icon:SetSimpleAnchor(RAEIH_Time, iX, iY)
		-- String
		RAEIH_Time_String = WM:CreateControl("RAEIH_Time_String", RAEIH_Time, CT_LABEL)
		RAEIH_Time_String:SetSimpleAnchor(RAEIH_Time, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Time_String:SetHorizontalAlignment(CENTER)
		RAEIH_Time_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Time_Backdrop = WM:CreateControl("RAEIH_Time_Backdrop", RAEIH_Time, CT_BACKDROP)
		RAEIH_Time_Backdrop:SetAnchorFill(RAEIH_Time)
		RAEIH_Time_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Time_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetTime()

	local clrDft = "|c" .. RAEIH.SavedVars.TimeDefaultColour

	local precisionType
	local timeValueInSeconds = GetSecondsSinceMidnight()
	local formatType = TIME_FORMAT_STYLE_CLOCK_TIME
	local date = GetDate()
	local month = string.sub(date, 5, 6)
	local day = string.sub(date, 7, 8)
	local year = string.sub(date, 1,4)

	if RAEIH.SavedVars.DateFormat == "MM/DD/YY" then
		date = month .. "/" .. day .. "/" .. year
	elseif RAEIH.SavedVars.DateFormat == "DD/MM/YY" then
		date = day .. "/" .. month .. "/" .. year
	end

	if RAEIH.SavedVars.Enable12HCF == true then
		precisionType = TIME_FORMAT_PRECISION_TWELVE_HOUR
	else
		precisionType = TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR
	end

	local direction = TIME_FORMAT_DIRECTION_NONE
	local formattedTimeString, nextUpdateTimeInSec = FormatTimeSeconds(timeValueInSeconds, formatType, precisionType, direction)

	if RAEIH.SavedVars.TimeFormat == "Time & Date" then
		RAEIH.TimeText = clrDft .. formattedTimeString .. " (" .. date .. ")"
	elseif RAEIH.SavedVars.TimeFormat == "Time" then
		RAEIH.TimeText = clrDft .. formattedTimeString
	elseif RAEIH.SavedVars.TimeFormat == "Date" then
		RAEIH.TimeText = clrDft .. date
	end
	RAEIH_Time_String:SetText(RAEIH.TimeText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatTime()

	local font = LMP:Fetch('font', RAEIH.SavedVars.TimeFont)
	local size = RAEIH.SavedVars.TimeFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.TimeFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Time_String:SetFont(fontFormat)

end

function RAEIH.OrganizeTime()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.TimeX
	local mY = RAEIH.SavedVars.TimeY
	local mW = RAEIH.SavedVars.TimeIconW + RAEIH_Time_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.TimeIconH
	local iX = RAEIH.SavedVars.TimeIconX
	local iY = RAEIH.SavedVars.TimeIconY
	local iW = RAEIH.SavedVars.TimeIconW
	local iH = RAEIH.SavedVars.TimeIconH
	local bA = RAEIH.SavedVars.TimeBA
	-- Update General Dimensions
	RAEIH_Time:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Time_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Time_Icon:ClearAnchors()
	RAEIH_Time_Icon:SetSimpleAnchor(RAEIH_Time, iX, iY)
	-- Update String Anchor
	RAEIH_Time_String:ClearAnchors()
	RAEIH_Time_String:SetSimpleAnchor(RAEIH_Time, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Time_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingTime()
	RAEIH_Time:StartMoving()
end

function RAEIH.StopMovingTime()
	RAEIH_Time:StopMovingOrResizing()
	RAEIH.SavedVars.TimeX = RAEIH_Time:GetLeft()
	RAEIH.SavedVars.TimeY = RAEIH_Time:GetTop()
end