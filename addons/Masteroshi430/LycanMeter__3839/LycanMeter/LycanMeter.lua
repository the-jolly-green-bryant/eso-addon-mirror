LycanMeter = {}
LycanMeter.name = "LycanMeter"

-- ============================================================
-- Tunables for the smoothing behavior
-- ============================================================
local SMOOTH_INTERVAL_MS = 50      -- how often we tick a transition
local SMOOTH_FACTOR       = 0.25    -- fraction of remaining distance covered per tick
local ANGLE_SNAP          = 0.005   -- close enough to goal angle -> snap
local PERCENT_SNAP        = 0.5     -- close enough to goal percent -> snap

-- ============================================================
-- One-time control creation. Anchors/textures/dimensions never
-- change after this, so they no longer get re-applied every
-- time LycanMeter.go() runs.
-- ============================================================
local function CreateCooldownCircle(parent)
	local circle = WINDOW_MANAGER:CreateControl(nil, parent, CT_COOLDOWN)
	circle:SetTexture("esoui/art/hud/infamy_meter-bounty_px_per.dds")
	circle:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
	circle:ClearAnchors()
	circle:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 15, 15)
	circle:SetHidden(false)
	circle.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_HUDInfamyMeterEasing")
	return circle
end

function LycanMeter.InitializeMeter()
	if LycanMeter.Meter then return end

	local meter = WINDOW_MANAGER:CreateTopLevelWindow(nil)
	meter:SetDimensions(INFAMY_METER_WIDTH, INFAMY_METER_HEIGHT)
	meter:ClearAnchors()
	meter:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
	meter:SetHidden(true)
	LycanMeter.Meter = meter

	-- background
	meter.CircleBg = WINDOW_MANAGER:CreateControl(nil, meter, CT_TEXTURE)
	meter.CircleBg:SetTexture("esoui/art/hud/infamy_meter-back-grey_px_per.dds")
	meter.CircleBg:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
	meter.CircleBg:ClearAnchors()
	meter.CircleBg:SetAnchor(BOTTOMRIGHT, meter, BOTTOMRIGHT, 15, 15)
	meter.CircleBg:SetHidden(false)

	-- the 5 stacked cooldown circles (kept as-is; this is a known trick
	-- to smooth the radial gradient blend). They're now built once via
	-- a shared helper instead of ~40 lines of copy/paste each.
	meter.Circle      = CreateCooldownCircle(meter)
	meter.CircleTwo   = CreateCooldownCircle(meter)
	meter.CircleThree = CreateCooldownCircle(meter)
	meter.CircleFour  = CreateCooldownCircle(meter)
	meter.CircleFive  = CreateCooldownCircle(meter)
	meter.circles = { meter.Circle, meter.CircleTwo, meter.CircleThree, meter.CircleFour, meter.CircleFive }

	-- frame
	meter.Texture = WINDOW_MANAGER:CreateControl(nil, meter, CT_TEXTURE)
	meter.Texture:SetTexture("esoui/art/hud/infamy_meter-frame-generic.dds")
	meter.Texture:SetDimensions(INFAMY_METER_WIDTH, INFAMY_METER_HEIGHT)
	meter.Texture:ClearAnchors()
	meter.Texture:SetAnchor(BOTTOMRIGHT, meter, BOTTOMRIGHT, 0, 0)
	meter.Texture:SetHidden(false)

	-- % text
	meter.Text = WINDOW_MANAGER:CreateControl(nil, meter, CT_LABEL)
	meter.Text:SetFont("$(BOLD_FONT)|20|soft-shadow-thick")
	meter.Text:SetDimensions(50, 20)
	meter.Text:ClearAnchors()
	meter.Text:SetAnchor(BOTTOMRIGHT, meter, BOTTOMRIGHT, -125, -15)
	meter.Text:SetHidden(false)

	-- icon
	meter.Icon = WINDOW_MANAGER:CreateControl(nil, meter, CT_TEXTURE)
	meter.Icon:SetTexture("esoui/art/icons/store_werewolfbite_01.dds")
	meter.Icon:SetDimensions(INFAMY_METER_HEIGHT / 2, INFAMY_METER_HEIGHT / 2)
	meter.Icon:ClearAnchors()
	meter.Icon:SetAnchor(BOTTOMRIGHT, meter, BOTTOMRIGHT, -17, -17)
	meter.Icon:SetHidden(false)

	-- reusable colour object so we're not allocating a new ZO_ColorDef
	-- every time the power updates. ZO_ColorDef doesn't expose a
	-- SetRGBA method, so we mutate the r/g/b/a fields directly
	-- (this is exactly what UnpackRGB/UnpackRGBA read from).
	meter.colour = ZO_ColorDef:New(1, 0, 0, 1)
end

-- ============================================================
-- Smooth gradient/angle transition.
-- Uses a single registered update handler instead of a chain of
-- zo_callLater closures, and moves a fraction of the remaining
-- distance each tick (converges fast for big jumps, still smooth
-- for small ones) instead of a fixed 0.01 rad/tick step.
-- ============================================================
local GRADIENT_UPDATE_KEY = "LycanMeter_GradientUpdate"

local function TickGradient()
	local meter = LycanMeter.Meter
	local circle = meter.Circle
	local goal = circle.angle or 0
	local current = circle.currentAngle or goal

	local diff = goal - current
	if math.abs(diff) <= ANGLE_SNAP then
		current = goal
	else
		current = current + diff * SMOOTH_FACTOR
	end
	circle.currentAngle = current

	for _, c in ipairs(meter.circles) do
		c:SetRadialCooldownGradient(1, current)
	end

	if current == goal then
		EVENT_MANAGER:UnregisterForUpdate(GRADIENT_UPDATE_KEY)
	end
end

function LycanMeter.SetGradient()
	EVENT_MANAGER:UnregisterForUpdate(GRADIENT_UPDATE_KEY)
	EVENT_MANAGER:RegisterForUpdate(GRADIENT_UPDATE_KEY, SMOOTH_INTERVAL_MS, TickGradient)
end

-- ============================================================
-- Smooth percent-text transition, same technique as above.
-- ============================================================
local PERCENT_UPDATE_KEY = "LycanMeter_PercentUpdate"

local function TickPercentText()
	local text = LycanMeter.Meter.Text
	local goal = text.percentageGoal or 0
	local current = text.percentage or goal

	local diff = goal - current
	if math.abs(diff) <= PERCENT_SNAP then
		current = goal
	else
		current = current + diff * SMOOTH_FACTOR
	end

	text.percentage = current
	text:SetText(zo_floor(current + 0.5) .. "%")

	if current == goal then
		EVENT_MANAGER:UnregisterForUpdate(PERCENT_UPDATE_KEY)
	end
end

function LycanMeter.SetPercentText()
	EVENT_MANAGER:UnregisterForUpdate(PERCENT_UPDATE_KEY)
	EVENT_MANAGER:RegisterForUpdate(PERCENT_UPDATE_KEY, SMOOTH_INTERVAL_MS, TickPercentText)
end

-- ============================================================
-- Main update. Only touches things that can actually change
-- from call to call (fill colour, cooldown percent, angle goal,
-- visibility). Static layout is set once in InitializeMeter().
-- ============================================================
function LycanMeter.go()
	if not IsPlayerActivated() then return end

	-- cheap check first: most calls (every scene change in the whole
	-- game, not just HUD) will bail out right here without ever
	-- touching GetBounty/IsInImperialCity/etc. or creating any controls
	if not IsPlayerInWerewolfForm() then
		if LycanMeter.Meter and not LycanMeter.Meter:IsHidden() then
			LycanMeter.Meter:SetHidden(true)
		end
		return
	end

	-- was a leaked global that, once set true, never reset to false
	-- for the rest of the session; now recomputed fresh every call
	local doNotDisplay = IsInImperialCity() or GetBounty() > 0 or GetLocalPlayerDaedricArtifactId() ~= nil

	if SCENE_MANAGER:GetCurrentSceneName() == "hud" and not doNotDisplay then
		-- controls are only ever created the first time we actually
		-- need to show the meter, same as the original addon
		LycanMeter.InitializeMeter()
		local meter = LycanMeter.Meter

		local current, max = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_WEREWOLF)
		if not current or not max or max == 0 then return end
		local percentage = math.floor(current / max * 100)

		-- skip all recompute/redraw work if nothing actually changed
		if meter.lastPercentage == percentage and not meter:IsHidden() then
			return
		end
		meter.lastPercentage = percentage

		local amount = percentage / 100
		meter.colour.r, meter.colour.g, meter.colour.b, meter.colour.a = 1, amount, amount, 1 -- red -> white lerp, no allocation
		local r, g, b = meter.colour:UnpackRGB()

		meter:SetHidden(false)

		local NO_LEADING_EDGE = false
		for _, c in ipairs(meter.circles) do
			c.startPercent = c.endPercent or 100
			c.endPercent = percentage
			c:StartFixedCooldown(c.startPercent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
			c.easeAnimation:PlayFromStart()
			c:SetFillColor(r, g, b)
		end

		local MAX_ROTATION = math.pi * 2
		meter.Circle.angle = math.floor(percentage * MAX_ROTATION) / 100
		LycanMeter.SetGradient()

		meter.Text:SetColor(r, g, b)
		meter.Text.percentageGoal = percentage
		LycanMeter.SetPercentText()
	else
		-- not on the HUD scene, or bounty/IC/artifact is hiding us:
		-- meter may not exist yet if we've never shown it this session
		if LycanMeter.Meter and not LycanMeter.Meter:IsHidden() then
			LycanMeter.Meter:SetHidden(true)
		end
	end
end

EVENT_MANAGER:RegisterForEvent(LycanMeter.name, EVENT_WEREWOLF_STATE_CHANGED, LycanMeter.go)
EVENT_MANAGER:RegisterForEvent(LycanMeter.name, EVENT_POWER_UPDATE, function(_, unitTag, _, powerType)
	if unitTag == "player" and powerType == COMBAT_MECHANIC_FLAGS_WEREWOLF then
		LycanMeter.go()
	end
end)

-- NOTE: this still fires on every scene-state change in the entire UI,
-- same as the original addon. The original hook's own parameter names
-- (rowControl, rowData) suggest its actual callback signature isn't
-- well understood, so rather than guess at it and risk silently
-- breaking meter updates, we keep the same trigger and instead make
-- each go() call cheap: it now bails out immediately (no table
-- creation, no GetBounty/IsInImperialCity calls) whenever the player
-- isn't a werewolf, which is true the vast majority of the time this
-- fires.
SecurePostHook(SCENE_MANAGER, "OnSceneStateChange", function(rowControl, rowData)
	LycanMeter.go()
end)
