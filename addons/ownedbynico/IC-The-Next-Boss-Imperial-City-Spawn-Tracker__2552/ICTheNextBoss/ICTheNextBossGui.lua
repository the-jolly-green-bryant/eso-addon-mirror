ICT.ui = {
	opened = false,
	mapid = 0,
	timetable = ZO_SimpleSceneFragment:New(ICTTimeTable),
	maptimers = ZO_SimpleSceneFragment:New(ICTMapTimers),
	
	districts = {
		[GetString(SI_ICTHENEXTBOSS_MEMORIALDISTRICT)] = ICTMemorialDistrictLabel,
		[GetString(SI_ICTHENEXTBOSS_ARENADISTRICT)] = ICTArenaDistrictLabel,
		[GetString(SI_ICTHENEXTBOSS_ARBORETUMDISTRICT)] = ICTArboretumDistrictLabel,
		[GetString(SI_ICTHENEXTBOSS_TEMPLEDISTRICT)] = ICTTempleDistrictLabel,
		[GetString(SI_ICTHENEXTBOSS_NOBLESDISTRICT)] = ICTNoblesDistrictLabel,
		[GetString(SI_ICTHENEXTBOSS_ELVENGARDENSDISTRICT)] = ICTElvenGardensDistrictLabel,
		[GetString(SI_ICTHENEXTBOSS_CAN)] = ICTCanLabel,
	}
}

function ICT.disableMapMouseWheelZoom()

	local function disableZoom(self, delta, force)
		if force ~= nil then return false end
		if ICT.running == true and ICT.savedVariables.maptimers == true and ICT.ui.mapid == 660 then
			ZO_WorldMapZoom_OnMouseWheel(-1000, _, true)
			return true
		end
	end

	-- These are private world-map internals, not stable API; only hook the ones
	-- that actually exist so a ZOS map refactor can't break our load.
	if _G['ZO_WorldMap_MouseWheel'] then ZO_PreHook('ZO_WorldMap_MouseWheel', disableZoom) end
	if _G['ZO_WorldMapZoom_OnMouseWheel'] then ZO_PreHook('ZO_WorldMapZoom_OnMouseWheel', disableZoom) end
	if _G['ZO_WorldMapZoomMinus_OnClicked'] then ZO_PreHook('ZO_WorldMapZoomMinus_OnClicked', disableZoom) end
	if _G['ZO_WorldMapZoomPlus_OnClicked'] then ZO_PreHook('ZO_WorldMapZoomPlus_OnClicked', disableZoom) end
end

function ICT.disableMapZoomSlider(boolean)
	-- Resolve each control by name and skip any that are missing, rather than
	-- hard-referencing globals that may not exist after a map UI change.
	local function setEnabled(name)
		local control = _G[name]
		if control then control:SetEnabled(not boolean) end
	end
	for i = 1, 11 do
		setEnabled('ZO_WorldMapZoomSliderButton' .. i)
	end
	setEnabled('ZO_WorldMapZoomMinus')
	setEnabled('ZO_WorldMapZoomPlus')
end

function ICT.onMapOpen()
	
	local function check()
		if ICT.running == true and ICT.ui.opened == true and ICT.savedVariables.maptimers == true and ICT.ui.mapid == 660 then
			ICTMapTimers:SetHidden(false)
			ICT.disableMapZoomSlider(true)
		else
			ICTMapTimers:SetHidden(true)
			ICT.disableMapZoomSlider(false)
		end
	end
	
	WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
	
		ICT.ui.mapid = GetCurrentMapId()
		
		if newState == SCENE_SHOWN or newState == SCENE_SHOWING then
			ICT.ui.opened = true
		else
			ICT.ui.opened = false
		end
		
		check()
	end)
	
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
		ICT.ui.mapid = GetCurrentMapId()
		check()
	end)
end

function ICT.onTableMove()
	ICT.savedVariables.timetableTop = ICTTimeTable:GetTop()
	ICT.savedVariables.timetableLeft = ICTTimeTable:GetLeft()
end

function ICT.restoreUIPosition()
	ICTTimeTable:ClearAnchors()
	ICTTimeTable:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ICT.savedVariables.timetableLeft, ICT.savedVariables.timetableTop)
end

function ICT.secondsToClock(sec)
	return string.format("%02d:%02d", math.floor(sec / 60), (sec % 60))
end

local HEADER_HEIGHT = 24
local TOP_PAD = 2
local BOTTOM_PAD = 6
local DEFAULT_ROW_HEIGHT = 26
local MIN_WIDTH, MAX_WIDTH = 180, 600
local MIN_ROW_HEIGHT, MAX_ROW_HEIGHT = 18, 64

local function chrome() return HEADER_HEIGHT + TOP_PAD + BOTTOM_PAD end

-- Build the HUD timetable as one fixed-order row per district (no reordering),
-- plus a single extra row used only in reduced mode.
function ICT.buildRows()
	if ICT.ui.rows then return end
	ICT.ui.rows = {}

	ICT.ui.header = ICTTimeTableHeader
	ICT.ui.collapseButton = ICTTimeTableHeaderCollapse
	ICT.ui.lockButton = ICTTimeTableHeaderLock

	-- Borderless background: solid centre, transparent edge (no frame colour).
	ICTTimeTableBG:SetCenterColor(0, 0, 0, 0.6)
	ICTTimeTableBG:SetEdgeColor(0, 0, 0, 0)

	ICT.initFade()

	local order = { 0, 1, 2, 3, 4, 5, 6 } -- Sewers, Memorial, Arena, Arboretum, Temple, Nobles, Elven Gardens
	local prev = nil
	for _, dindex in ipairs(order) do
		local districtName = GetString(ICT.datas[dindex])
		local row = CreateControlFromVirtual("ICTRow" .. dindex, ICTTimeTable, "ICTRowTemplate")
		row:ClearAnchors()
		if prev then
			row:SetAnchor(TOPLEFT, prev, BOTTOMLEFT, 0, 0)
			row:SetAnchor(TOPRIGHT, prev, BOTTOMRIGHT, 0, 0)
		else
			row:SetAnchor(TOPLEFT, ICTTimeTableHeader, BOTTOMLEFT, 0, TOP_PAD)
			row:SetAnchor(TOPRIGHT, ICTTimeTableHeader, BOTTOMRIGHT, 0, TOP_PAD)
		end
		row.districtName = districtName
		row.districtIndex = dindex
		ICT.ui.rows[districtName] = row
		prev = row
	end

	local nextRow = CreateControlFromVirtual("ICTNextRow", ICTTimeTable, "ICTRowTemplate")
	nextRow:ClearAnchors()
	nextRow:SetAnchor(TOPLEFT, ICTTimeTableHeader, BOTTOMLEFT, 0, TOP_PAD)
	nextRow:SetAnchor(TOPRIGHT, ICTTimeTableHeader, BOTTOMRIGHT, 0, TOP_PAD)
	nextRow:SetHidden(true)
	ICT.ui.nextRow = nextRow

	ICTTimeTable:SetDimensionConstraints(
		MIN_WIDTH, chrome() + MIN_ROW_HEIGHT,
		MAX_WIDTH, chrome() + MAX_ROW_HEIGHT * 7)

	ICT.applyDisplayMode()
	ICT.applyLock()
end

-- Paints a row's name, timer, accent bar and boss icon for a given status.
function ICT.paintRow(row, label, color, clock, r, g, b)
	row:GetNamedChild("Name"):SetText(color .. label .. "|r")
	row:GetNamedChild("Timer"):SetText(color .. clock .. "|r")
	row:GetNamedChild("Accent"):SetCenterColor(r, g, b, 1)
	row:GetNamedChild("Icon"):SetColor(r, g, b, 1)
end

-- Switches between full (all districts) and reduced (next district only) layout:
-- toggles which controls are visible, flips the arrow and resizes the box.
function ICT.applyDisplayMode()
	local sv = ICT.savedVariables
	local reduced = sv.reduced == true
	local rowHeight = sv.rowHeight or DEFAULT_ROW_HEIGHT
	local count = reduced and 1 or 7

	ICTTimeTable:SetWidth(sv.boxWidth or 345)

	if ICT.ui.rows then
		for _, row in pairs(ICT.ui.rows) do
			row:SetHidden(reduced)
			row:SetHeight(rowHeight)
		end
	end
	if ICT.ui.nextRow then
		ICT.ui.nextRow:SetHidden(not reduced)
		ICT.ui.nextRow:SetHeight(rowHeight)
	end
	if ICT.ui.collapseButton then
		-- Swap ALL three states, not just normal: otherwise hovering/pressing the
		-- button in reduced mode shows the stale up-arrow mouseOver texture, which
		-- looks like a second "collapse" arrow appearing over the expand button.
		local dir = reduced and "down" or "up"
		local base = "EsoUI/Art/Buttons/scrollbox_" .. dir .. "Arrow_"
		ICT.ui.collapseButton:SetNormalTexture(base .. "up.dds")
		ICT.ui.collapseButton:SetPressedTexture(base .. "down.dds")
		ICT.ui.collapseButton:SetMouseOverTexture(base .. "over.dds")
	end

	ICTTimeTable:SetHeight(chrome() + rowHeight * count)
end

-- Drag-resize: width widens the rows (so names stop truncating); height changes
-- the per-row height. Both are persisted and re-applied on load.
function ICT.onResize()
	local sv = ICT.savedVariables
	local w = ICTTimeTable:GetWidth()
	if w < MIN_WIDTH then w = MIN_WIDTH elseif w > MAX_WIDTH then w = MAX_WIDTH end
	sv.boxWidth = w

	local count = (sv.reduced == true) and 1 or 7
	local rh = (ICTTimeTable:GetHeight() - chrome()) / count
	if rh < MIN_ROW_HEIGHT then rh = MIN_ROW_HEIGHT elseif rh > MAX_ROW_HEIGHT then rh = MAX_ROW_HEIGHT end
	sv.rowHeight = rh

	ICT.applyDisplayMode()
end

-- Fills the reduced-mode row with the current "next" district, keeping its
-- start/reset buttons (and tooltip) pointed at that district.
function ICT.updateNextRow()
	local row = ICT.ui.nextRow
	if row == nil then return end

	local nextName = ICT.getNextDistrict()
	if nextName == nil then
		row.districtName = nil
		row.districtIndex = nil
		ICT.paintRow(row, GetString(SI_ICTHENEXTBOSS_NO_TIMERS), "|c3399FF", "--:--", 0.20, 0.60, 1.00)
		return
	end

	row.districtName = nextName
	row.districtIndex = ICT.getDistrictID(nextName)
	local color, clock, r, g, b = ICT.statusInfo(ICT.timetable[nextName])
	ICT.paintRow(row, nextName, color, clock, r, g, b)
end

function ICT.setRowButtons(row, shown)
	local s = row:GetNamedChild("Start")
	local r = row:GetNamedChild("Reset")
	if s then s:SetHidden(not shown) end
	if r then r:SetHidden(not shown) end
end

-- Reveal a row's action buttons on hover; hide on exit. Also refresh opacity so
-- the box snaps to full while the cursor is over it. The Start/Reset buttons
-- forward their own enter/exit here (via the XML) so leaving a button straight
-- out of the box still hides them.
function ICT.onRowEnter(row)
	ICT.setRowButtons(row, true)
	ICT.refreshAlpha()
end

function ICT.onRowExit(row)
	-- Moving the cursor onto one of the row's own buttons fires this exit even
	-- though we're still inside the row -- don't hide them then, or they flicker
	-- out from under the cursor and eat the click.
	if MouseIsOver(row) then return end
	ICT.setRowButtons(row, false)
	ICT.refreshAlpha()
end

-- Safety net for a missed mouse-exit (fast cursor moves, or the box fading out
-- from under the cursor): once the cursor is off the whole box, no row should
-- still be showing its hover buttons. Polled from the 1s update loop.
function ICT.pruneRowButtons()
	if MouseIsOver(ICTTimeTable) then return end
	if ICT.ui.rows then
		for _, row in pairs(ICT.ui.rows) do ICT.setRowButtons(row, false) end
	end
	if ICT.ui.nextRow then ICT.setRowButtons(ICT.ui.nextRow, false) end
end

-- One-time alpha animator for fading the box in/out.
function ICT.initFade()
	if ICT.fadeTimeline then return end
	ICT.fadeTimeline = ANIMATION_MANAGER:CreateTimeline()
	ICT.fadeAnim = ICT.fadeTimeline:InsertAnimation(ANIMATION_ALPHA, ICTTimeTable)
	ICT.fadeAnim:SetDuration(250)
	ICT.fadeTimeline:SetHandler("OnStop", function()
		-- Hide for real only once a fade-out finished, so a hidden box stops
		-- catching the mouse. pendingHide is cleared whenever we retarget to show.
		if ICT.pendingHide then ICTTimeTable:SetHidden(true) end
	end)
end

-- The box belongs to the HUD scenes only. Our fade loop drives SetHidden/SetAlpha
-- directly every tick, which otherwise overrides the scene fragment and repaints
-- the box on top of any open menu (inventory, map, settings, ...). Mirroring the
-- scene state into computeHidden() keeps it hidden whenever the player isn't in
-- normal gameplay, and the StateChange callbacks make that happen instantly
-- rather than on the next 1s tick.
function ICT.inHudScene()
	return HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing()
end

function ICT.initSceneVisibility()
	if ICT.sceneVisInit then return end
	ICT.sceneVisInit = true
	local function onSceneState() ICT.refreshVisibility() end
	HUD_SCENE:RegisterCallback("StateChange", onSceneState)
	HUD_UI_SCENE:RegisterCallback("StateChange", onSceneState)
end

-- True when the box should be hidden (not in gameplay / master toggle off /
-- combat / moving).
function ICT.computeHidden()
	if ICT.running ~= true then return true end -- not in IC: box never shows
	if ICT.savedVariables.timetable ~= true then return true end
	if not ICT.inHudScene() then return true end
	if ICT.savedVariables.hideInCombat and ICT.inCombat then return true end
	if ICT.savedVariables.hideMoving and ICT.isMoving then return true end
	return false
end

-- Fade the box toward a target alpha (0 = hidden). animate=false applies instantly.
function ICT.fadeTo(target, animate)
	if ICT.fadeTimeline == nil then
		ICTTimeTable:SetHidden(target <= 0)
		ICTTimeTable:SetAlpha(target)
		return
	end
	ICT.pendingHide = (target <= 0)
	if target > 0 then ICTTimeTable:SetHidden(false) end -- must be shown to fade in

	if animate == false then
		ICT.fadeTimeline:Stop()
		ICTTimeTable:SetAlpha(target)
		if target <= 0 then ICTTimeTable:SetHidden(true) end
		return
	end

	local current = ICTTimeTable:GetAlpha()
	if math.abs(current - target) < 0.01 then
		if target <= 0 then ICTTimeTable:SetHidden(true) end
		return
	end
	ICT.fadeAnim:SetAlphaValues(current, target)
	ICT.fadeTimeline:PlayFromStart()
end

-- Recompute the box's correct alpha (hidden / hover-full / configured opacity)
-- and fade to it.
function ICT.updateBox(animate)
	local target
	if ICT.computeHidden() then
		target = 0
	elseif MouseIsOver(ICTTimeTable) then
		target = 1
	else
		target = (ICT.savedVariables.opacity or 60) / 100
	end
	ICT.fadeTo(target, animate)
end

-- Entry points used throughout the addon; both just recompute + fade.
function ICT.refreshAlpha() ICT.updateBox(true) end
function ICT.refreshVisibility() ICT.updateBox(true) end

function ICT.onCombatState(_, inCombat)
	ICT.inCombat = inCombat
	ICT.refreshVisibility()
end

-- Polled ~10x/s while in IC: flags movement by comparing world position.
-- Debounced so stop-start movement (strafing, jumping, the combat shuffle)
-- doesn't flash the box in and out: hides immediately on the first movement,
-- but only treats the player as "stopped" after a short still period.
local STILL_GRACE_MS = 600
function ICT.checkMovement()
	local _, x, _, z = GetUnitWorldPosition("player")
	local moving = (math.abs(x - (ICT.lastX or x)) + math.abs(z - (ICT.lastZ or z))) > 5
	ICT.lastX, ICT.lastZ = x, z

	local now = GetGameTimeMilliseconds()
	if moving then
		ICT.lastMoveTime = now
		if not ICT.isMoving then
			ICT.isMoving = true
			ICT.refreshVisibility()
		end
	elseif ICT.isMoving and (now - (ICT.lastMoveTime or 0)) > STILL_GRACE_MS then
		ICT.isMoving = false
		ICT.refreshVisibility()
	end
end

-- Header buttons.
function ICT.toggleReduced()
	ICT.savedVariables.reduced = not (ICT.savedVariables.reduced == true)
	ICT.applyDisplayMode()
end

function ICT.openSettings()
	if LibAddonMenu2 and ICT.settingsPanel then
		LibAddonMenu2:OpenToPanel(ICT.settingsPanel)
	end
end

function ICT.applyLock()
	local locked = ICT.savedVariables.locked == true
	ICTTimeTable:SetMovable(not locked)
	ICTTimeTable:SetResizeHandleSize(locked and 0 or 8) -- also disable resizing when locked
	if ICT.ui.lockButton then
		ICT.ui.lockButton:SetAlpha(locked and 1 or 0.4) -- dim when unlocked
	end
end

function ICT.toggleLock()
	ICT.savedVariables.locked = not (ICT.savedVariables.locked == true)
	ICT.applyLock()
end

-- Start button handler: marks the district's boss as killed (starts its timer
-- with the correct 15-min / 5-min Molag duration), same as /ictnb <n>.
function ICT.onStartButton(button)
	local row = button:GetParent()
	if row and row.districtIndex then
		ICT.markDistrict(row.districtIndex)
	end
end

-- Reset button handler: each button lives inside its district's row.
function ICT.onResetButton(button)
	local row = button:GetParent()
	if row and row.districtName then
		ICT.resetDistrict(row.districtName)
	end
end