local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateCoordinates()
	local WM = GetWindowManager()
	if RAEIH_Coordinates == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.CoordinatesX
		local mY = RAEIH.SavedVars.CoordinatesY
		local mW = RAEIH.SavedVars.CoordinatesIconW + 10
		local mH = RAEIH.SavedVars.CoordinatesIconH
		local iX = RAEIH.SavedVars.CoordinatesIconX
		local iY = RAEIH.SavedVars.CoordinatesIconY
		local iW = RAEIH.SavedVars.CoordinatesIconW
		local iH = RAEIH.SavedVars.CoordinatesIconH
		local bA = RAEIH.SavedVars.CoordinatesBA
		-- Main Placeholder
		RAEIH_Coordinates = WM:CreateTopLevelWindow("RAEIH_Coordinates")
		RAEIH_Coordinates:SetClampedToScreen(true)
		RAEIH_Coordinates:SetDrawLevel(1)
		RAEIH_Coordinates:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Coordinates:SetMouseEnabled(true)
		RAEIH_Coordinates:SetMovable(not RAEIH.SavedVars.LockCoordinates)
		RAEIH_Coordinates:SetHandler("OnReceiveDrag", RAEIH.StartMovingCoordinates)
		RAEIH_Coordinates:SetHandler("OnMouseUp", RAEIH.StopMovingCoordinates)
		RAEIH_Coordinates:SetHidden(not RAEIH.SavedVars.ShowCoordinates)
		-- Icon
		RAEIH_Coordinates_Icon = WM:CreateControl("RAEIH_Coordinates_Icon", RAEIH_Coordinates, CT_TEXTURE)
		RAEIH_Coordinates_Icon:SetTexture(RAEIH.Icons.Coordinates)
		RAEIH_Coordinates_Icon:SetDimensions(iW, iH)
		RAEIH_Coordinates_Icon:SetSimpleAnchor(RAEIH_Coordinates, iX, iY)
		-- String
		RAEIH_Coordinates_String = WM:CreateControl("RAEIH_Coordinates_String", RAEIH_Coordinates, CT_LABEL)
		RAEIH_Coordinates_String:SetSimpleAnchor(RAEIH_Coordinates, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Coordinates_String:SetHorizontalAlignment(CENTER)
		RAEIH_Coordinates_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Coordinates_Backdrop = WM:CreateControl("RAEIH_Coordinates_Backdrop", RAEIH_Coordinates, CT_BACKDROP)
		RAEIH_Coordinates_Backdrop:SetAnchorFill(RAEIH_Coordinates)
		RAEIH_Coordinates_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Coordinates_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetCoordinates()

	local clrDft = "|c" .. RAEIH.SavedVars.CoordinatesDefaultColour
	local clrX = "|c" .. RAEIH.SavedVars.CoordinatesXColour
	local clrY = "|c" .. RAEIH.SavedVars.CoordinatesYColour

	local formattedX, formattedY, heading = GetMapPlayerPosition(uTag)
	local posX = string.format("%05.02f", RAEIH.Round(formattedX * 100, 2))
	local posY = string.format("%05.02f", RAEIH.Round(formattedY * 100, 2))

	RAEIH.CoordinatesText = clrDft  .. "X: " .. clrX .. posX .. clrDft .. "/" .. "Y: " .. clrY .. posY
	RAEIH_Coordinates_String:SetText(RAEIH.CoordinatesText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatCoordinates()

	local font = LMP:Fetch('font', RAEIH.SavedVars.CoordinatesFont)
	local size = RAEIH.SavedVars.CoordinatesFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.CoordinatesFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Coordinates_String:SetFont(fontFormat)

end

function RAEIH.OrganizeCoordinates()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.CoordinatesX
	local mY = RAEIH.SavedVars.CoordinatesY
	local mW = RAEIH.SavedVars.CoordinatesIconW + RAEIH_Coordinates_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.CoordinatesIconH
	local iX = RAEIH.SavedVars.CoordinatesIconX
	local iY = RAEIH.SavedVars.CoordinatesIconY
	local iW = RAEIH.SavedVars.CoordinatesIconW
	local iH = RAEIH.SavedVars.CoordinatesIconH
	local bA = RAEIH.SavedVars.CoordinatesBA
	-- Update General Dimensions
	RAEIH_Coordinates:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Coordinates_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Coordinates_Icon:ClearAnchors()
	RAEIH_Coordinates_Icon:SetSimpleAnchor(RAEIH_Coordinates, iX, iY)
	-- Update String Anchor
	RAEIH_Coordinates_String:ClearAnchors()
	RAEIH_Coordinates_String:SetSimpleAnchor(RAEIH_Coordinates, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Coordinates_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingCoordinates()
	RAEIH_Coordinates:StartMoving()
end

function RAEIH.StopMovingCoordinates()
	RAEIH_Coordinates:StopMovingOrResizing()
	RAEIH.SavedVars.CoordinatesX = RAEIH_Coordinates:GetLeft()
	RAEIH.SavedVars.CoordinatesY = RAEIH_Coordinates:GetTop()
end