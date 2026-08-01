local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateFriends()
	local WM = GetWindowManager()
	if RAEIH_Friends == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.FriendsX
		local mY = RAEIH.SavedVars.FriendsY
		local mW = RAEIH.SavedVars.FriendsIconW + 10
		local mH = RAEIH.SavedVars.FriendsIconH
		local iX = RAEIH.SavedVars.FriendsIconX
		local iY = RAEIH.SavedVars.FriendsIconY
		local iW = RAEIH.SavedVars.FriendsIconW
		local iH = RAEIH.SavedVars.FriendsIconH
		local bA = RAEIH.SavedVars.FriendsBA
		-- Main Placeholder
		RAEIH_Friends = WM:CreateTopLevelWindow("RAEIH_Friends")
		RAEIH_Friends:SetClampedToScreen(true)
		RAEIH_Friends:SetDrawLevel(1)
		RAEIH_Friends:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Friends:SetMouseEnabled(true)
		RAEIH_Friends:SetMovable(not RAEIH.SavedVars.LockFriends)
		RAEIH_Friends:SetHandler("OnReceiveDrag", RAEIH.StartMovingFriends)
		RAEIH_Friends:SetHandler("OnMouseUp", RAEIH.StopMovingFriends)
		RAEIH_Friends:SetHidden(not RAEIH.SavedVars.ShowFriends)
		-- Icon
		RAEIH_Friends_Icon = WM:CreateControl("RAEIH_Friends_Icon", RAEIH_Friends, CT_TEXTURE)
		RAEIH_Friends_Icon:SetTexture(RAEIH.Icons.Friends)
		RAEIH_Friends_Icon:SetDimensions(iW, iH)
		RAEIH_Friends_Icon:SetSimpleAnchor(RAEIH_Friends, iX, iY)
		-- String
		RAEIH_Friends_String = WM:CreateControl("RAEIH_Friends_String", RAEIH_Friends, CT_LABEL)
		RAEIH_Friends_String:SetSimpleAnchor(RAEIH_Friends, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Friends_String:SetHorizontalAlignment(CENTER)
		RAEIH_Friends_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Friends_Backdrop = WM:CreateControl("RAEIH_Friends_Backdrop", RAEIH_Friends, CT_BACKDROP)
		RAEIH_Friends_Backdrop:SetAnchorFill(RAEIH_Friends)
		RAEIH_Friends_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Friends_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetFriends()

	local clrDft = "|c" .. RAEIH.SavedVars.FriendsDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.FriendsAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.FriendsWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.FriendsNormalColour
	local clr = clrDft

	local total = GetNumFriends()
	local online = 0
	local offline = 0

	for i = 1, total, 1 do
		displayName, note, playerStatus, secsSinceLogoff = GetFriendInfo(i)

		if playerStatus == 4 then
			offline = offline + 1
		else
			online = online + 1
		end
	end

	if online == 0 then
		clr = clrA
	elseif online == total then
		clr = clrN
	else
		clr = clrW
	end
	if RAEIH.SavedVars.FriendsFormat == "Online/Total (Offline)" then
		RAEIH.FriendsText = clr .. online .. clrDft .. "/" .. total .. " (O: " .. clr .. offline .. clrDft .. ")"
	elseif RAEIH.SavedVars.FriendsFormat == "Online/Total" then
		RAEIH.FriendsText = clr .. online .. clrDft .. "/" .. total
	elseif RAEIH.SavedVars.FriendsFormat == "Online/Offline" then
		RAEIH.FriendsText = clr .. online .. clrDft .. "/" .. clr .. offline
	end
	RAEIH_Friends_String:SetText(RAEIH.FriendsText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatFriends()

	local font = LMP:Fetch('font', RAEIH.SavedVars.FriendsFont)
	local size = RAEIH.SavedVars.FriendsFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.FriendsFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Friends_String:SetFont(fontFormat)

end

function RAEIH.OrganizeFriends()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.FriendsX
	local mY = RAEIH.SavedVars.FriendsY
	local mW = RAEIH.SavedVars.FriendsIconW + RAEIH_Friends_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.FriendsIconH
	local iX = RAEIH.SavedVars.FriendsIconX
	local iY = RAEIH.SavedVars.FriendsIconY
	local iW = RAEIH.SavedVars.FriendsIconW
	local iH = RAEIH.SavedVars.FriendsIconH
	local bA = RAEIH.SavedVars.FriendsBA
	-- Update General Dimensions
	RAEIH_Friends:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Friends_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Friends_Icon:ClearAnchors()
	RAEIH_Friends_Icon:SetSimpleAnchor(RAEIH_Friends, iX, iY)
	-- Update String Anchor
	RAEIH_Friends_String:ClearAnchors()
	RAEIH_Friends_String:SetSimpleAnchor(RAEIH_Friends, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Friends_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingFriends()
	RAEIH_Friends:StartMoving()
end

function RAEIH.StopMovingFriends()
	RAEIH_Friends:StopMovingOrResizing()
	RAEIH.SavedVars.FriendsX = RAEIH_Friends:GetLeft()
	RAEIH.SavedVars.FriendsY = RAEIH_Friends:GetTop()
end