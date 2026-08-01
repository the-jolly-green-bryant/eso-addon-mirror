--local function SetAnchorOffsets(control, offsetX, offsetY)
--	local isValid, point, target, relPoint = control:GetAnchor(0)
--	if isValid then
--		control:SetAnchor(point, target, relPoint, offsetX, offsetY)
--	end
--end

--        local screenHeight = GuiRoot:GetHeight()
--        local controlHeight = control:GetHeight()
--        local offsetY = (screenHeight - controlHeight) / 2
--	control:ClearAnchors()
--        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 245, offsetY)


NoCompass = {
    name = "NoCompass",
    vars = { },  -- Saved variables
    defaults = { compassIsHidden = true },
}

-- Should be localized but I'm lazy while it's not my primary language ^^
function NoCompass:showMessage(active)
	local lmsg = "Compass : "
	if active then
		lmsg = lmsg .. "Disabled"
	else
		lmsg = lmsg .. "Enabled"
	end
	d(lmsg)
end

--
-- Hides or Show Compass
--
function NoCompass:hideFrame(aHidden)
-- frame
	local lCompassFrame = COMPASS_FRAME.control
	if lCompassFrame then
		for lIndex, lPos in pairs({"Left", "Center", "Right"}) do
			lWidget = lCompassFrame:GetNamedChild(lPos)
			lWidget:SetHidden(aHidden)
		end
		-- instead of hidding pins (Harvestmap relies on them, don't ask me why)
		-- I add an offset of (16384, 16384) to top left of pins container
		local ldecale = 0
		if aHidden then ldecale = 16384 end
		ZO_Compass:SetAnchor(TOPLEFT, lCompassFrame, TOPLEFT, ldecale, ldecale)
	end
end

-- not used in version 9+
function NoCompass:hidePinsAndText(aHidden)
	-- pins
	local lCompassPins = COMPASS.control
	if lCompassPins then
		local lWidget = lCompassPins:GetNamedChild("Container")
		lWidget:SetHidden(aHidden)
	end
	-- above text
	if aHidden then
		COMPASS.centerOverPinLabel:SetText("")
	end
end

function NoCompass:setHidden(aHidden)
	-- compass and frame
	NoCompass:hideFrame(aHidden)
	-- NoCompass:hidePinsAndText(aHidden)
end

--
-- Called by keystroke
--
function NoCompass:toggleCompass()
	NoCompass.vars.compassIsHidden = not NoCompass.vars.compassIsHidden
	local bossActive = COMPASS_FRAME:GetBossBarActive()
	local t = NoCompass.vars.compassIsHidden and not bossActive
	NoCompass:setHidden(t)
	NoCompass:showMessage(NoCompass.vars.compassIsHidden)
end

-- called when boss bar becomes inactive
function NoCompass:restoreCompassState()
	local t = NoCompass.vars.compassIsHidden 
	NoCompass:setHidden(t)
end

--
-- Show or Hides compass without parameter (bypass init giving addr as arg)
--
function NoCompass:hideCompass()
	NoCompass.vars.compassIsHidden = false
	NoCompass:toggleCompass()
end

function NoCompass:showCompass()
	NoCompass.vars.compassIsHidden = true
	NoCompass:toggleCompass()
end

--
-- Initialization
--
function NoCompass:Init()
	NoCompass.vars = ZO_SavedVars:NewAccountWide("NoCompassVars", 1, nil, NoCompass.defaults)
	if NoCompass.vars.compassIsHidden then
		NoCompass:hideCompass()
	else
		NoCompass:showCompass()
	end
	-- NoCompass.showMessage(NoCompass.vars.compassIsHidden)

	-- original hook idea from Drummerx04, October 2018, on the forum
	-- https://forums.elderscrollsonline.com/en/discussion/437510/how-to-remove-default-boss-bar-when-using-lui-ext
	-- though I don't want to remove the bar but keep it instead ^^
	do
	-- Unhide compass frame when a boss is near
		local framefunc = COMPASS_FRAME.SetBossBarActive
		function COMPASS_FRAME:SetBossBarActive(active)
			if active then
				NoCompass:hideFrame(false)
				self:RefreshVisible(self)
				framefunc(self, true)
			else
				framefunc(self, false)
				NoCompass:restoreCompassState()
			end
		end
	end
	-- end of hook

	SLASH_COMMANDS["/compno"] = function() NoCompass:hideCompass() end
	SLASH_COMMANDS["/compyes"] = function() NoCompass:showCompass() end
	ZO_CreateStringId("SI_BINDING_NAME_COMPASS_ITEM", "Toggle Compass")
end

function NoCompass.OnAddonLoaded(eventCode, aName)
    if aName == NoCompass.name then
	EVENT_MANAGER:UnregisterForEvent(NoCompass.name, eventCode)
	NoCompass:Init()
    end
end	

EVENT_MANAGER:RegisterForEvent(NoCompass.name, EVENT_ADD_ON_LOADED, NoCompass.OnAddonLoaded )
