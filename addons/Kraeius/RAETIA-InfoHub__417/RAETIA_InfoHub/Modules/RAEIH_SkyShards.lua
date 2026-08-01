local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateSkyShards()
	local WM = GetWindowManager()
	if RAEIH_SkyShards == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.SkyShardsX
		local mY = RAEIH.SavedVars.SkyShardsY
		local mW = RAEIH.SavedVars.SkyShardsIconW + 10
		local mH = RAEIH.SavedVars.SkyShardsIconH
		local iX = RAEIH.SavedVars.SkyShardsIconX
		local iY = RAEIH.SavedVars.SkyShardsIconY
		local iW = RAEIH.SavedVars.SkyShardsIconW
		local iH = RAEIH.SavedVars.SkyShardsIconH
		local bA = RAEIH.SavedVars.SkyShardsBA
		-- Main Placeholder
		RAEIH_SkyShards = WM:CreateTopLevelWindow("RAEIH_SkyShards")
		RAEIH_SkyShards:SetClampedToScreen(true)
		RAEIH_SkyShards:SetDrawLevel(1)
		RAEIH_SkyShards:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_SkyShards:SetMouseEnabled(true)
		RAEIH_SkyShards:SetMovable(not RAEIH.SavedVars.LockSkyShards)
		RAEIH_SkyShards:SetHandler("OnReceiveDrag", RAEIH.StartMovingSkyShards)
		RAEIH_SkyShards:SetHandler("OnMouseUp", RAEIH.StopMovingSkyShards)
		RAEIH_SkyShards:SetHidden(not RAEIH.SavedVars.ShowSkyShards)
		-- Icon
		RAEIH_SkyShards_Icon = WM:CreateControl("RAEIH_SkyShards_Icon", RAEIH_SkyShards, CT_TEXTURE)
		RAEIH_SkyShards_Icon:SetTexture(RAEIH.Icons.SkyShards)
		RAEIH_SkyShards_Icon:SetDimensions(iW, iH)
		RAEIH_SkyShards_Icon:SetSimpleAnchor(RAEIH_SkyShards, iX, iY)
		-- String
		RAEIH_SkyShards_String = WM:CreateControl("RAEIH_SkyShards_String", RAEIH_SkyShards, CT_LABEL)
		RAEIH_SkyShards_String:SetSimpleAnchor(RAEIH_SkyShards, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_SkyShards_String:SetHorizontalAlignment(CENTER)
		RAEIH_SkyShards_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_SkyShards_Backdrop = WM:CreateControl("RAEIH_SkyShards_Backdrop", RAEIH_SkyShards, CT_BACKDROP)
		RAEIH_SkyShards_Backdrop:SetAnchorFill(RAEIH_SkyShards)
		RAEIH_SkyShards_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_SkyShards_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetSkyShards()

	local clrDft = "|c" .. RAEIH.SavedVars.SkyShardsDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.SkyShardsAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.SkyShardsWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.SkyShardsNormalColour
	local clr = clrDft

	local ssNum = GetNumSkyShards()
	local ssNumCap = 3

	if ssNum == 0 then
		clr = clrA
	elseif ssNum == 1 then
		clr = clrW
	elseif ssNum == 2 then
		clr = clrN
	else
		clr = clrN
	end

	RAEIH.SkyShardsText = clr .. ssNum .. clrDft .. "/" .. ssNumCap
	RAEIH_SkyShards_String:SetText(RAEIH.SkyShardsText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatSkyShards()

	local font = LMP:Fetch('font', RAEIH.SavedVars.SkyShardsFont)
	local size = RAEIH.SavedVars.SkyShardsFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.SkyShardsFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_SkyShards_String:SetFont(fontFormat)

end

function RAEIH.OrganizeSkyShards()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.SkyShardsX
	local mY = RAEIH.SavedVars.SkyShardsY
	local mW = RAEIH.SavedVars.SkyShardsIconW + RAEIH_SkyShards_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.SkyShardsIconH
	local iX = RAEIH.SavedVars.SkyShardsIconX
	local iY = RAEIH.SavedVars.SkyShardsIconY
	local iW = RAEIH.SavedVars.SkyShardsIconW
	local iH = RAEIH.SavedVars.SkyShardsIconH
	local bA = RAEIH.SavedVars.SkyShardsBA
	-- Update General Dimensions
	RAEIH_SkyShards:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_SkyShards_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_SkyShards_Icon:ClearAnchors()
	RAEIH_SkyShards_Icon:SetSimpleAnchor(RAEIH_SkyShards, iX, iY)
	-- Update String Anchor
	RAEIH_SkyShards_String:ClearAnchors()
	RAEIH_SkyShards_String:SetSimpleAnchor(RAEIH_SkyShards, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_SkyShards_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingSkyShards()
	RAEIH_SkyShards:StartMoving()
end

function RAEIH.StopMovingSkyShards()
	RAEIH_SkyShards:StopMovingOrResizing()
	RAEIH.SavedVars.SkyShardsX = RAEIH_SkyShards:GetLeft()
	RAEIH.SavedVars.SkyShardsY = RAEIH_SkyShards:GetTop()
end