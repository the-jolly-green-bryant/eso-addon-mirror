--
-- This file handles the window to display.
--

local wm = GetWindowManager()

if MD == nil then MD = {} end

--
--
--
function MD.MakeWindow()
	-- our primary window
	MD.window = wm:CreateTopLevelWindow("MassDeconstructorWindows")

    local hws = MD.window
	hws:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MD.settings.x, MD.settings.y)
	hws:SetMovable(true)
	hws:SetHidden(not MD.settings.shown)
	hws:SetMouseEnabled(true)
	hws:SetClampedToScreen(true)
	hws:SetDimensions(0,0)
	hws:SetResizeToFitDescendents(true)
	hws:SetHandler("OnMoveStop", function()
		MD.settings.x = hws:GetLeft()
		MD.settings.y = hws:GetTop()
	end)
	
	-- give it a backdground (backdrop) for the frame
	hws.bg = wm:CreateControl("HWSBackground", hws, CT_BACKDROP)
	hws.bg:SetAnchorFill(hws)
	--hws.bg:SetCenterColor(0, 0, 0, MD.settings.alpha / 100)
	--hws.bg:SetEdgeColor(0, 0, 0, MD.settings.alpha / 100)
	hws.bg:SetEdgeTexture(nil, 2, 2, 0, 0)
	hws.bg:SetExcludeFromResizeToFitExtents(true)
	hws.bg:SetDrawLayer(DL_BACKGROUND)
	
	-- give it a header
	hws.title = wm:CreateControl("HWSTitle", hws, CT_LABEL)
	hws.title:SetAnchor(TOP, hws, TOP, 0, 5)
	hws.title:SetFont("EsoUi/Common/Fonts/Univers67.otf|18|soft-shadow-thin")
	hws.title:SetColor(.9, .9, .7, 1)
	hws.title:SetStyleColor(0, 0, 0, 1)
	hws.title:SetText("Hello World")
	hws.title:SetHidden(not MD.settings.showtitle)
	
	-- Give it a zone label
	hws.zone = wm:CreateControl("HWSZone", hws, CT_LABEL)
	if (MD.settings.showtitle) then
		hws.zone:SetAnchor(TOP, hws.title, BOTTOM, 0, 5)
	else
		hws.zone:SetAnchor(TOP, hws, TOP, 0, 5)
	end
	hws.zone:SetFont("EsoUi/Common/Fonts/Univers67.otf|17|soft-shadow-thin")
	hws.zone:SetColor(.9, .9, .7, 1)
	hws.zone:SetStyleColor(0, 0, 0, 1)
	hws.zone:SetText("Zone Name")

	-- make a container for the list entries
	hws.entries = wm:CreateControl("HWSEntries", hws, CT_CONTROL)
	hws.entries:SetAnchor(TOP, hws.zone, BOTTOM, 0, 0)
	hws.entries:SetHidden(false)
	hws.entries:SetResizeToFitDescendents(true)

	-- add a bit of padding
	hws.entries:SetResizeToFitPadding(20, 10)
	
	-- hide our window when the compass frame gets hidden, if it's not hidden already
	if ZO_CompassFrame:IsHandlerSet("OnShow") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnShow")
		ZO_CompassFrame:SetHandler("OnShow", function(...) oldHandler(...) if MD.settings.shown then MD.window:SetHidden(false) end end)
	else
		ZO_CompassFrame:SetHandler("OnShow", function(...) if MD.settings.shown then MD.window:SetHidden(false) end end)
	end
	if ZO_CompassFrame:IsHandlerSet("OnHide") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnHide")
		ZO_CompassFrame:SetHandler("OnHide", function(...) oldHandler(...) if MD.settings.shown then MD.window:SetHidden(true) end end)
	else
		ZO_CompassFrame:SetHandler("OnHide", function(...) if MD.settings.shown then MD.window:SetHidden(true) end end)
	end
end

--
--
--
function MD.PopulateWindow(zone, achievement)
	if MD.window == nil then MD.MakeWindow() end
	MD.window.zone:SetText(zone)
	
	local lowAlpha = 0.4
	local highAlpha = 1

	MD.window:SetHidden(ZO_CompassFrame:IsHidden() or not MD.settings.shown)
end


--
-- Show or hide the window
--
function MD.ToggleWindow()
	local ishidden = MD.window:IsHidden()
	-- refresh the window if we're about to show it
	if ishidden then MD.RefreshWindow() end
	MD.settings.shown = ishidden
	MD.window:SetHidden(not ishidden)
end