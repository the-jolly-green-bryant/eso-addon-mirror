BountyTimeDisplay={}

BountyTimeDisplay.name="BountyTimeDisplay"
BountyTimeDisplay.bountylength=0
BountyTimeDisplay.manualPlacement=false
BountyTimeDisplay.mergeDays=true
BountyTimeDisplay.updateQueued=false

local SECONDS_MINUTE=60
local SECONDS_HOUR=SECONDS_MINUTE*60
local SECONDS_DAY=SECONDS_HOUR*24

local INITIAL_OFFSET=-29
local INITIAL_OFFSET_GAMEPAD=10
local GLYPH_PADDING=2
local GLYPH_PADDING_GAMEPAD=2
local GLYPH_OFFSET=8
local GLYPH_OFFSET_GAMEPAD=24


local mfloor=math.floor

function BountyTimeDisplay.SecondsToDelta(seconds, mergeDays)
	local d = 0
	if not mergeDays then
		d = mfloor(seconds / SECONDS_DAY)
	end
	local h = mfloor((seconds - (SECONDS_DAY * d)) / SECONDS_HOUR)
	local m = mfloor((seconds - ((SECONDS_DAY * d) + (SECONDS_HOUR * h))) / SECONDS_MINUTE)
	local s = (seconds - ((SECONDS_DAY * d) + (SECONDS_HOUR * h) + (SECONDS_MINUTE * m)))
	return d, h, m, s
end

function BountyTimeDisplay.BountyTimeDisplayString()
	local bountyTimeLeft = GetSecondsUntilBountyDecaysToZero()
	local days, hours, minutes, seconds = BountyTimeDisplay.SecondsToDelta(bountyTimeLeft, BountyTimeDisplay.mergeDays)
	if days ~= 0 then
		return string.format("%d, %02d:%02d:%02d", days, hours, minutes, seconds)
	else
		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	end
end

function BountyTimeDisplay.BountyTimeDisplayPrint()
	d(BountyTimeDisplay.BountyTimeDisplayString())
end

function BountyTimeDisplay.AdjustPosition(currentbountylength)
	if IsInGamepadPreferredMode() then
		BountyTimeDisplay.control:SetAnchor(CENTER, ZO_HUDInfamyMeterBountyDisplay, CENTER, INITIAL_OFFSET_GAMEPAD+((currentbountylength+GLYPH_PADDING_GAMEPAD)*GLYPH_OFFSET_GAMEPAD), 0)
	else
		BountyTimeDisplay.control:SetAnchor(CENTER, ZO_HUDInfamyMeterBountyDisplay, CENTER, INITIAL_OFFSET-((currentbountylength+GLYPH_PADDING)*GLYPH_OFFSET), 0)
	end
end

function BountyTimeDisplay.UpdateControl()
	BountyTimeDisplay.updateQueued=false
	if IsInJusticeEnabledZone() then
		if not ZO_HUDInfamyMeter:IsHidden() then
			local currentbountylength = #tostring(GetFullBountyPayoffAmount())
			if currentbountylength ~=nil and (not BountyTimeDisplay.manualPlacement) and currentbountylength ~= BountyTimeDisplay.bountylength then
				BountyTimeDisplay.control:ClearAnchors()
				BountyTimeDisplay.AdjustPosition(currentbountylength)
				BountyTimeDisplay.bountylength = currentbountylength
			end
		end
		BountyTimeDisplay.control:SetText(BountyTimeDisplay.BountyTimeDisplayString())
		local timeRemaining = GetSecondsUntilBountyDecaysToZero()
		if timeRemaining ~= 0 then
			if not BountyTimeDisplay.updateQueued then
				EVENT_MANAGER:RegisterForUpdate("BountyTimeDisplayTick", 1000, BountyTimeDisplay.UpdateControl)
				BountyTimeDisplay.updateQueued=true
			end
		else
			EVENT_MANAGER:UnregisterForUpdate("BountyTimeDisplayTick")
			BountyTimeDisplay.bountylength=0
		end
	else
		BountyTimeDisplay.bountylength=0
	end
end

function BountyTimeDisplay.UpdateThrottle()
	if not BountyTimeDisplay.updateQueued then
		BountyTimeDisplay.UpdateControl()
	end
end

function BountyTimeDisplay.DebugAnchor(val)
	BountyTimeDisplay.manualPlacement=true
	BountyTimeDisplay.control:ClearAnchors()
	BountyTimeDisplay.control:SetAnchor(CENTER, ZO_HUDInfamyMeterBountyDisplay, CENTER, val, 0)
end

function BountyTimeDisplay.GamepadModeChange(event, gamepadMode)
	if gamepadMode then
		BountyTimeDisplay.control:SetFont("ZoFontGamepad42")
		BountyTimeDisplay.control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	else
		BountyTimeDisplay.control:SetFont("ZoFontGameLargeBoldShadow")
		BountyTimeDisplay.control:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	end
	BountyTimeDisplay.AdjustPosition(BountyTimeDisplay.bountylength)
end

function BountyTimeDisplay.OnAddonLoaded(event, addonName)
	if addonName == BountyTimeDisplay.name then
		BountyTimeDisplay.control = CreateControl("BountyTimeDisplayControl", ZO_HUDInfamyMeterBountyDisplay, CT_LABEL )
		BountyTimeDisplay.control:SetColor(1, 0.098039217293262, 0.098039217293262, 1)
		BountyTimeDisplay.GamepadModeChange(EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, IsInGamepadPreferredMode())
		BountyTimeDisplay.control:SetDrawTier(DT_MEDIUM)
		BountyTimeDisplay.control:SetDrawLevel(6)
		EVENT_MANAGER:RegisterForEvent(BountyTimeDisplay.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, BountyTimeDisplay.GamepadModeChange)
		EVENT_MANAGER:RegisterForEvent(BountyTimeDisplay.name, EVENT_JUSTICE_INFAMY_UPDATED, BountyTimeDisplay.UpdateThrottle)
		EVENT_MANAGER:RegisterForEvent(BountyTimeDisplay.name, EVENT_PLAYER_ACTIVATED, BountyTimeDisplay.UpdateThrottle)
		SLASH_COMMANDS["/bountytime"] = BountyTimeDisplay.BountyTimeDisplayPrint
		--SLASH_COMMANDS["/bt"] = BountyTimeDisplay.BountyTimeDisplayPrint
	end
end

EVENT_MANAGER:RegisterForEvent(BountyTimeDisplay.name, EVENT_ADD_ON_LOADED, BountyTimeDisplay.OnAddonLoaded)