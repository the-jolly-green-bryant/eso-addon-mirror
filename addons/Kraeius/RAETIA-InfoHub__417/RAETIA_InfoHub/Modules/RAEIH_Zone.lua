local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateZone()
	local WM = GetWindowManager()
	if RAEIH_Zone == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.ZoneX
		local mY = RAEIH.SavedVars.ZoneY
		local mW = RAEIH.SavedVars.ZoneIconW + 10
		local mH = RAEIH.SavedVars.ZoneIconH
		local iX = RAEIH.SavedVars.ZoneIconX
		local iY = RAEIH.SavedVars.ZoneIconY
		local iW = RAEIH.SavedVars.ZoneIconW
		local iH = RAEIH.SavedVars.ZoneIconH
		local bA = RAEIH.SavedVars.ZoneBA
		-- Main Placeholder
		RAEIH_Zone = WM:CreateTopLevelWindow("RAEIH_Zone")
		RAEIH_Zone:SetClampedToScreen(true)
		RAEIH_Zone:SetDrawLevel(1)
		RAEIH_Zone:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Zone:SetMouseEnabled(true)
		RAEIH_Zone:SetMovable(not RAEIH.SavedVars.LockZone)
		RAEIH_Zone:SetHandler("OnReceiveDrag", RAEIH.StartMovingZone)
		RAEIH_Zone:SetHandler("OnMouseUp", RAEIH.StopMovingZone)
		RAEIH_Zone:SetHidden(not RAEIH.SavedVars.ShowZone)
		-- Icon
		RAEIH_Zone_Icon = WM:CreateControl("RAEIH_Zone_Icon", RAEIH_Zone, CT_TEXTURE)
		RAEIH_Zone_Icon:SetTexture(RAEIH.Icons.Zone)
		RAEIH_Zone_Icon:SetDimensions(iW, iH)
		RAEIH_Zone_Icon:SetSimpleAnchor(RAEIH_Zone, iX, iY)
		-- String
		RAEIH_Zone_String = WM:CreateControl("RAEIH_Zone_String", RAEIH_Zone, CT_LABEL)
		RAEIH_Zone_String:SetSimpleAnchor(RAEIH_Zone, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Zone_String:SetHorizontalAlignment(CENTER)
		RAEIH_Zone_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Zone_Backdrop = WM:CreateControl("RAEIH_Zone_Backdrop", RAEIH_Zone, CT_BACKDROP)
		RAEIH_Zone_Backdrop:SetAnchorFill(RAEIH_Zone)
		RAEIH_Zone_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Zone_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetZone()

	local clrDft = "|c" .. RAEIH.SavedVars.ZoneDefaultColour
	local clrSZ = "|c" .. RAEIH.SavedVars.SubzoneColour
	local clrZ = "|c" .. RAEIH.SavedVars.ZoneColour

	local subZone = GetPlayerLocationName()
	local mainZone = GetUnitZone(uTag)
	local wmTitle = ZO_WorldMapTitle:GetText()

	if RAEIH.SavedVars.ZoneFormat == "Subzone (Zone)" and subZone == mainZone then
		RAEIH.ZoneText = clrSZ .. subZone
	elseif RAEIH.SavedVars.ZoneFormat == "Subzone (Zone)" then
		RAEIH.ZoneText = clrSZ .. subZone .. clrDft .. " (" .. clrZ .. mainZone .. clrDft .. ")"		
    elseif RAEIH.SavedVars.ZoneFormat == "Subzone" then
        RAEIH.ZoneText = clrSZ .. subZone
    elseif RAEIH.SavedVars.ZoneFormat == "Zone" then
        RAEIH.ZoneText = clrZ .. mainZone
    end
	RAEIH_Zone_String:SetText(RAEIH.ZoneText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatZone()

	local font = LMP:Fetch('font', RAEIH.SavedVars.ZoneFont)
	local size = RAEIH.SavedVars.ZoneFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.ZoneFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Zone_String:SetFont(fontFormat)

end

function RAEIH.OrganizeZone()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.ZoneX
	local mY = RAEIH.SavedVars.ZoneY
	local mW = RAEIH.SavedVars.ZoneIconW + RAEIH_Zone_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.ZoneIconH
	local iX = RAEIH.SavedVars.ZoneIconX
	local iY = RAEIH.SavedVars.ZoneIconY
	local iW = RAEIH.SavedVars.ZoneIconW
	local iH = RAEIH.SavedVars.ZoneIconH
	local bA = RAEIH.SavedVars.ZoneBA
	-- Update General Dimensions
	RAEIH_Zone:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Zone_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Zone_Icon:ClearAnchors()
	RAEIH_Zone_Icon:SetSimpleAnchor(RAEIH_Zone, iX, iY)
	-- Update String Anchor
	RAEIH_Zone_String:ClearAnchors()
	RAEIH_Zone_String:SetSimpleAnchor(RAEIH_Zone, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Zone_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingZone()
	RAEIH_Zone:StartMoving()
end

function RAEIH.StopMovingZone()
	RAEIH_Zone:StopMovingOrResizing()
	RAEIH.SavedVars.ZoneX = RAEIH_Zone:GetLeft()
	RAEIH.SavedVars.ZoneY = RAEIH_Zone:GetTop()
end

function RAEIH.AutoWMZ()
	local isWorldMapHidden = ZO_WorldMap:IsHidden()
	if RAEIH.SavedVars.AWMZ and
		isWorldMapHidden == false
		and RAEIH.SavedVars.ZDone == false then
		local zLvl = RAEIH.SavedVars.WMZLvl
		local i = 2
		while i <= zLvl do
			ZO_WorldMapZoomMinus_OnClicked()
			i = i + 1
		end
	end
end