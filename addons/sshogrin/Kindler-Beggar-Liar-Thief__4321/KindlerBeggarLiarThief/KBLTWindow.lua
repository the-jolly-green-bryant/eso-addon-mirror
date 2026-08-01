if not KBLT then KBLT = {} end

function KBLT.NewWindow()
	local window = WINDOW_MANAGER:CreateTopLevelWindow("KBLTWindow")
	window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, KBLT.settings.x, KBLT.settings.y)
	window:SetMovable(true)
	window:SetHidden(not KBLT.settings.shown)
	window:SetMouseEnabled(true)
	window:SetClampedToScreen(true)
	window:SetResizeToFitDescendents(true)
	window:SetResizeToFitPadding(20, 20)
	window:SetHandler("OnMoveStop", function()
		KBLT.settings.x = window:GetLeft()
		KBLT.settings.y = window:GetTop()
	end)
	
	window.bg = WINDOW_MANAGER:CreateControl("KBLTWindowBG", window, CT_BACKDROP)
	window.bg:SetAnchorFill(window)
	window.bg:SetCenterColor(0, 0, 0, KBLT.settings.alpha / 100)
	window.bg:SetEdgeColor(0, 0, 0, KBLT.settings.alpha / 100)
	window.bg:SetEdgeTexture(nil, 2, 2, 0, 0)
	window.bg:SetExcludeFromResizeToFitExtents(true)
	window.bg:SetDrawLayer(DL_BACKGROUND)

	-- zone name
	window.zone = WINDOW_MANAGER:CreateControl("KBLTZone", window, CT_LABEL)
	window.zone:SetAnchor(TOP, window, TOP, 0, 5)
	window.zone:SetFont("EsoUi/Common/Fonts/Univers67.otf|17|soft-shadow-thin")
	window.zone:SetColor(.9, .9, .7, 1)
	window.zone:SetStyleColor(0,0,0,1)
	window.zone:SetText("Zone Name")
	
	window.kindler = WINDOW_MANAGER:CreateControl("KBLTKindler", window, CT_LABEL)
	window.kindler:SetAnchor(TOP, window.zone, BOTTOM, 0, 5)
	window.kindler:SetFont("EsoUi/Common/Fonts/Univers67.otf|15|soft-shadow-thin")
	window.kindler:SetColor(1, 1, 1, 1)
	window.kindler:SetStyleColor(0, 0, 0, 1)
	window.kindler:SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, KBLT.data.kindler.name) or "Lightbringer")
	
	window.beggar = WINDOW_MANAGER:CreateControl("KBLTBeggar", window, CT_LABEL)
	window.beggar:SetAnchor(TOP, window.kindler, BOTTOM, 0, 5)
	window.beggar:SetFont("EsoUi/Common/Fonts/Univers67.otf|15|soft-shadow-thin")
	window.beggar:SetColor(1, 1, 1, 1)
	window.beggar:SetStyleColor(0, 0, 0, 1)
	window.beggar:SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, KBLT.data.beggar.name) or "Give to the Poor")
	
	window.liar = WINDOW_MANAGER:CreateControl("KBLTLiar", window, CT_LABEL)
	window.liar:SetAnchor(TOP, window.beggar, BOTTOM, 0, 5)
	window.liar:SetFont("EsoUi/Common/Fonts/Univers67.otf|15|soft-shadow-thin")
	window.liar:SetColor(1, 1, 1, 1)
	window.liar:SetStyleColor(0, 0, 0, 1)
	window.liar:SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, KBLT.data.liar.name) or "I Like M'aiq")

	window.thief = WINDOW_MANAGER:CreateControl("KBLTThief", window, CT_LABEL)
	window.thief:SetAnchor(TOP, window.liar, BOTTOM, 0, 5)
	window.thief:SetFont("EsoUi/Common/Fonts/Univers67.otf|15|soft-shadow-thin")
	window.thief:SetColor(1, 1, 1, 1)
	window.thief:SetStyleColor(0, 0, 0, 1)
	window.thief:SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, KBLT.data.thief.name) or "Crime Pays")
	
	if ZO_CompassFrame:IsHandlerSet("OnHide") then
		local oldFunc = ZO_CompassFrame:GetHandler("OnHide")
		ZO_CompassFrame:SetHandler("OnHide", function(...)
			oldFunc(...)
			window:SetHidden(true)
		end)
	else
		ZO_CompassFrame:SetHandler("OnHide", function(...) window:SetHidden(true) end)
	end
	if ZO_CompassFrame:IsHandlerSet("OnShow") then
		local oldFunc = ZO_CompassFrame:GetHandler("OnShow")
		ZO_CompassFrame:SetHandler("OnShow", function(...)
			oldFunc(...)
			window:SetHidden(not KBLT.settings.shown)
		end)
	else
		ZO_CompassFrame:SetHandler("OnShow", function(...) window:SetHidden(not KBLT.settings.shown) end)
	end
	
	KBLT.window = window
end

function KBLT.UpdateWindow(zone)
	if not KBLT.window then KBLT.NewWindow() end

	local found, notFound
	if KBLT.settings.highlight == "Completed" then
		notFound = 0.4
		found = 1
	else
		notFound = 1
		found = 0.4
	end

	KBLT.window.zone:SetText(zone)

	if KBLT.data.kindler.zones[zone] == nil then
		KBLT.window.kindler:SetColor(1, 0, 0)
	else
		KBLT.window.kindler:SetColor(1, 1, 1)
	end
	KBLT.window.kindler:SetAlpha(KBLT.data.kindler.zones[zone] and found or notFound)
	
	if KBLT.data.beggar.zones[zone] == nil then
		KBLT.window.beggar:SetColor(1, 0, 0)
	else
		KBLT.window.beggar:SetColor(1, 1, 1)
	end
	KBLT.window.beggar:SetAlpha(KBLT.data.beggar.zones[zone] and found or notFound)

	if KBLT.data.liar.zones[zone] == nil then
		KBLT.window.liar:SetColor(1, 0, 0)
	else
		KBLT.window.liar:SetColor(1, 1, 1)
	end
	KBLT.window.liar:SetAlpha(KBLT.data.liar.zones[zone] and found or notFound)
	
	if KBLT.data.thief.zones[zone] == nil then
		KBLT.window.thief:SetColor(1, 0, 0)
	else
		KBLT.window.thief:SetColor(1, 1, 1)
	end
	KBLT.window.thief:SetAlpha(KBLT.data.thief.zones[zone] and found or notFound)
end

function KBLT.ToggleWindow()
	local wasHidden = KBLT.window:IsHidden()
	KBLT.settings.shown = wasHidden
	if wasHidden then KBLT.UpdateZone() end
	KBLT.window:SetHidden(not wasHidden)
end