local LMP = RAEIH.LMP
local LAN = RAEIH.LAN
local uTag = "player"

function RAEIH.FirstTextAnim()
	if A_Text == nil then
		A_Text = LAN:New()
		A_Text:AlphaToFrom(1, 0.1, 500)
		A_Text:Apply(RAEIH_Notification)
		A_Text:Play()
		RAEIH.SavedVars.AnimTracker = true
		RAEIH.SavedVars.AnimStage = 1
	elseif A_Text ~= nil then
		A_Text:AlphaToFrom(1, 0.1, 500)
		A_Text:Apply(RAEIH_Notification)
		A_Text:Play()
		RAEIH.SavedVars.AnimTracker = true
		RAEIH.SavedVars.AnimStage = 1
	end
end

function RAEIH.SecondTextAnim()
	if A_Text ~= nil then
		A_Text:AlphaToFrom(0.1, 1, 500)
		A_Text:Apply(RAEIH_Notification)
		A_Text:Play()
		RAEIH.SavedVars.AnimStage = 2
	end
end

function RAEIH.CreateNotification()
	local WM = GetWindowManager()
	if RAEIH_Notification == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.NotificationX
		local mY = RAEIH.SavedVars.NotificationY
		local mW = RAEIH.SavedVars.NotificationIconW + 10
		local mH = RAEIH.SavedVars.NotificationIconH
		local iX = RAEIH.SavedVars.NotificationIconX
		local iY = RAEIH.SavedVars.NotificationIconY
		local iW = RAEIH.SavedVars.NotificationIconW
		local iH = RAEIH.SavedVars.NotificationIconH
		local bA = RAEIH.SavedVars.NotificationBA
		-- Main Placeholder
		RAEIH_Notification = WM:CreateTopLevelWindow("RAEIH_Notification")
		RAEIH_Notification:SetClampedToScreen(true)
		RAEIH_Notification:SetDrawLevel(1)
		RAEIH_Notification:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Notification:SetMouseEnabled(true)
		RAEIH_Notification:SetMovable(not RAEIH.SavedVars.LockNotification)
		RAEIH_Notification:SetHandler("OnReceiveDrag", RAEIH.StartMovingNotification)
		RAEIH_Notification:SetHandler("OnMouseUp", RAEIH.StopMovingNotification)
		RAEIH_Notification:SetHidden(not RAEIH.SavedVars.ShowNotification)
		-- Icon
		RAEIH_Notification_Icon = WM:CreateControl("RAEIH_Notification_Icon", RAEIH_Notification, CT_TEXTURE)
		RAEIH_Notification_Icon:SetTexture(RAEIH.Icons.Notification)
		RAEIH_Notification_Icon:SetDimensions(iW, iH)
		RAEIH_Notification_Icon:SetSimpleAnchor(RAEIH_Notification, iX, iY)
		-- String
		RAEIH_Notification_String = WM:CreateControl("RAEIH_Notification_String", RAEIH_Notification, CT_LABEL)
		RAEIH_Notification_String:SetSimpleAnchor(RAEIH_Notification, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Notification_String:SetHorizontalAlignment(CENTER)
		RAEIH_Notification_String:SetVerticalAlignment(CENTER)
		RAEIH_Notification_String:SetText("No Message")
		-- Backdrop
		RAEIH_Notification_Backdrop = WM:CreateControl("RAEIH_Notification_Backdrop", RAEIH_Notification, CT_BACKDROP)
		RAEIH_Notification_Backdrop:SetAnchorFill(RAEIH_Notification)
		RAEIH_Notification_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Notification_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetNotification(eventCode, messageType, fromName, text)
	if messageType == 2 and RAEIH.SavedVars.NotificationWhisper == true then
		fromName = SplitString("^", fromName)
		local clrDft = "|c" .. RAEIH.SavedVars.NotificationDefaultColour
		local clrA = "|c" .. RAEIH.SavedVars.NotificationAlertColour
		local clrS = "|c" .. RAEIH.SavedVars.NotificationWarningColour
		RAEIH.NotificationText = clrA .. "Got a whisper from " .. clrS .. fromName .. clrA .. "!"
		RAEIH_Notification_String:SetText(RAEIH.NotificationText)
		RAEIH.FirstTextAnim()
		RAEIH.SavedVars.StartNotificationTimer = true
		RAEIH.OrganizeLegatus()
	end
end

function RAEIH.FormatNotification()

	local font = LMP:Fetch('font', RAEIH.SavedVars.NotificationFont)
	local size = RAEIH.SavedVars.NotificationFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.NotificationFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Notification_String:SetFont(fontFormat)

end

function RAEIH.OrganizeNotification()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.NotificationX
	local mY = RAEIH.SavedVars.NotificationY
	local mW = RAEIH.SavedVars.NotificationIconW + RAEIH_Notification_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.NotificationIconH
	local iX = RAEIH.SavedVars.NotificationIconX
	local iY = RAEIH.SavedVars.NotificationIconY
	local iW = RAEIH.SavedVars.NotificationIconW
	local iH = RAEIH.SavedVars.NotificationIconH
	local bA = RAEIH.SavedVars.NotificationBA
	-- Update General Dimensions
	RAEIH_Notification:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Notification_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Notification_Icon:ClearAnchors()
	RAEIH_Notification_Icon:SetSimpleAnchor(RAEIH_Notification, iX, iY)
	-- Update String Anchor
	RAEIH_Notification_String:ClearAnchors()
	RAEIH_Notification_String:SetSimpleAnchor(RAEIH_Notification, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Notification_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingNotification()
	RAEIH_Notification:StartMoving()
end

function RAEIH.StopMovingNotification()
	RAEIH_Notification:StopMovingOrResizing()
	RAEIH.SavedVars.NotificationX = RAEIH_Notification:GetLeft()
	RAEIH.SavedVars.NotificationY = RAEIH_Notification:GetTop()
end