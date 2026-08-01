DwFury = DwFury or {}

local EM = GetEventManager()

DwFury.name = "DwFury"
DwFury.version = "1.11"
DwFury.varVersion = "1"
DwFury.debugLevel = 0
DwFury.debugPrefix = "[DwFury] "
DwFury.debugMsgCount = 0

DwFury.updateInterval = 100

DwFury.effectId = 76950
DwFury.procDuration = 5000
DwFury.procStacks = 20
DwFury.procTime = 0
DwFury.inCombat = false
DwFury.stackCount = 0
DwFury.onCooldown = false
DwFury.alertSoundName = "NEW_TIMED_NOTIFICATION"

DwFury.defaults = {
	["offsetX"] = 500,
	["offsetY"] = 500,
	["stackTextSize"] = 28,
	["scale"] = 1,
	["showOutOfCombat"] = true,
	["showOnlyWhenActive"] = false,
	["playAlertSound"] = false,
	["enlargeBy"] = .2
}

function DwFury.debugMsg(level, ...)
	if level <= DwFury.debugLevel then
		DwFury.debugMsgCount = DwFury.debugMsgCount + 1
		local message = zo_strformat(...)
		d(DwFury.debugPrefix.."["..DwFury.debugMsgCount.."] "..message)
	end
end

function DwFury.setPosition()
	local x, y = DwFury.savedVars.offsetX, DwFury.savedVars.offsetY
	local wh = 50 * DwFury.savedVars.scale
	DwFuryFrame:ClearAnchors()
	DwFuryFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
	DwFuryFrame:SetDimensions(wh, wh)
end

function DwFury.setMaxStackPosition()
	local x, y = DwFury.savedVars.offsetX, DwFury.savedVars.offsetY
	local wh = 50 * DwFury.savedVars.scale
	x = x - ((wh * DwFury.savedVars.enlargeBy) / 2)
	y = y - ((wh * DwFury.savedVars.enlargeBy) / 2)
	DwFuryFrame:ClearAnchors()
	DwFuryFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
	DwFuryFrame:SetDimensions(wh * (DwFury.savedVars.enlargeBy + 1), wh * (DwFury.savedVars.enlargeBy + 1))
end

function DwFury.savePosition()
	DwFury.savedVars.offsetX = DwFuryFrame:GetLeft()
	DwFury.savedVars.offsetY = DwFuryFrame:GetTop()
end

function DwFury.setFontSize(size)
	DwFuryFrameStacks:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size, 'soft-shadow-thick'))
	DwFuryFrameTime:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size / 2, 'soft-shadow-thick'))
end

function DwFury.showHide()
	local shown = (DwFury.stackCount > 0 or DwFury.onCooldown or not DwFury.savedVars.showOnlyWhenActive) and (DwFury.inCombat or DwFury.savedVars.showOutOfCombat)
	DwFury.debugMsg(1, "Show the addon: <<1>>", tostring(shown))

	if shown then
		DwFuryFrame:SetHidden(false)
	else
		DwFuryFrame:SetHidden(true)
	end
end

function DwFury.combatState(_, inCombat)
	DwFury.inCombat = inCombat
	DwFury.debugMsg(1, "In combat: <<1>>", tostring(inCombat))
	DwFury.showHide()
end

function DwFury.resetDisplay()
	DwFury.setPosition()
	DwFury.stackCount = 0
	DwFuryFrameTexture:SetColor(1, 1, 1, .4)
	DwFuryFrameStacks:SetColor(1, 1, 1, 1)
	DwFuryFrameTime:SetColor(1, 1, 1, 1)
	DwFuryFrameStacks:SetText("")
	DwFuryFrameTime:SetText("")

	DwFury.showHide()
end

function DwFury.coolDown()
	local duration = DwFury.procDuration;

	if DwFury.stackCount == DwFury.procStacks then
		duration = duration * 2;
	end

	if GetGameTimeMilliseconds() - DwFury.procTime < duration then
		local displayTime = ((DwFury.procTime + DwFury.updateInterval - GetGameTimeMilliseconds()) / 1000) + (duration / 1000)
		if displayTime < 10 then
			DwFuryFrameTime:SetText(string.format("%.1f", displayTime))
		else
			DwFuryFrameTime:SetText(string.format("%.0f", displayTime))
		end
	else
		EM:UnregisterForUpdate(DwFury.name.."Cooldown")
		DwFury.onCooldown = false
		DwFury.resetDisplay()
	end
end

function DwFury.furyStack(_, result, _, abilityName, _, _, sourceName, _, _, _, _, _, _, _, _, _, abilityId)
	DwFury.debugMsg(2, "Name: <<1>> ID: <<2>> with result <<3>> from source: <<4>>", abilityName, abilityId, result, sourceName)
	if abilityId == DwFury.effectId and zo_strformat(SI_UNIT_NAME, sourceName) == zo_strformat(SI_UNIT_NAME, GetUnitName("player")) then
		if not DwFury.onCooldown then
			DwFuryFrameTexture:SetColor(1, 1, 1, 1)
			DwFury.showHide()
			EM:RegisterForUpdate(DwFury.name.."Cooldown", DwFury.updateInterval, DwFury.coolDown)
		end

		DwFury.onCooldown = true
		if DwFury.stackCount < DwFury.procStacks then
			DwFury.procTime = GetGameTimeMilliseconds()
			DwFury.stackCount = DwFury.stackCount + 1
			DwFury.showHide()
		end
		DwFury.debugMsg(1, "Current stack count "..DwFury.stackCount)
		DwFuryFrameStacks:SetText(DwFury.stackCount)

		if DwFury.stackCount == DwFury.procStacks then
			DwFuryFrameTexture:SetColor(1, 0, 0, 1)
			DwFury.setMaxStackPosition()
		end

		-- Play a sound when max stacks are hit
		if DwFury.stackCount == DwFury.procStacks and DwFury.savedVars.playAlertSound == true then
			PlaySound(SOUNDS[DwFury.alertSoundName])
		end
	end
end

function DwFury.Init(event, addon)
	if addon ~= DwFury.name then return end
	EM:UnregisterForEvent(DwFury.name.."Load", EVENT_ADD_ON_LOADED)

	DwFury.savedVars = ZO_SavedVars:New(DwFury.name.."SavedVars", DwFury.varVersion, nil, DwFury.defaults)
	DwFury.Settings.Init()

	DwFury.setFontSize(DwFury.savedVars.stackTextSize * DwFury.savedVars.scale)
	DwFury.resetDisplay()

  local furyFrameFragment = ZO_HUDFadeSceneFragment:New(DwFuryFrame, nil, 0)
  HUD_SCENE:AddFragment(furyFrameFragment)
  HUD_UI_SCENE:AddFragment(furyFrameFragment)

	local hudSceneChange = function(oldState, newState)
		DwFury.debugMsg(2, "HUD state changed (old/new): <<1>> / <<2>>", tostring(oldState), tostring(newState))
		DwFury.showHide()

		-- Transitioning to a menu/non-HUD
		-- if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
		-- 	DwFury.showHide()
		-- end

		-- Transitioning to a HUD/non-menu
		-- if newState == SCENE_SHOWING then
		-- 	DwFury.showHide()
		-- end
	end

	HUD_SCENE:RegisterCallback("StateChange", hudSceneChange)

	EM:RegisterForEvent(DwFury.name.."Combat", EVENT_PLAYER_COMBAT_STATE, DwFury.combatState)
	EM:RegisterForEvent(DwFury.name.."Stack", EVENT_COMBAT_EVENT, DwFury.furyStack)
	EM:AddFilterForEvent(DwFury.name.."Stack", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
end

EM:RegisterForEvent(DwFury.name.."Load", EVENT_ADD_ON_LOADED, DwFury.Init)
