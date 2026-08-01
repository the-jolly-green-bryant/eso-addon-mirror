Pillage = {}

Pillage.name = "Pillage"
Pillage.defaults	= {
  enabled = true,
	["offsetX"]	= 500,
	["offsetY"]	= 500,
	["timerSize"]	= 24,
	["passiveHide"]	= false,
}
Pillage.PillagerID = 172055
Pillage.CDID = 172056 -- Pillager's Profit Cooldown
Pillage.buffDuration = 0
Pillage.endTime = 0
Pillage.COLORS = {
	["UP"] = {
		0, 1, 0,
	},
	["DOWN"] = {
		1, 0, 0,
	}
}


function Pillage.setPos()
	local x, y = Pillage.savedVars.offsetX, Pillage.savedVars.offsetY
	PillageFrame:ClearAnchors()
	PillageFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function Pillage.savePos()
	Pillage.savedVars.offsetX = PillageFrame:GetLeft()
	Pillage.savedVars.offsetY = PillageFrame:GetTop()
end

function Pillage.setFontSize(size)
	PillageFrameTime:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size, 'soft-shadow-thick'))
end

function Pillage:Initialize()
  -- EVENT_MANAGER:RegisterForEvent(Pillage.name, EVENT_PLAYER_ACTIVATED, Pillage.CheckActivation)

  Pillage.setFontSize(Pillage.savedVars.timerSize)
	Pillage.setPos()
	PillageFrame:SetHidden(false)
	PillageFrameTime:SetColor(1,1,1)

  EVENT_MANAGER:RegisterForEvent(Pillage.name, EVENT_EFFECT_CHANGED, Pillage.EffectChanged)
  EVENT_MANAGER:AddFilterForEvent(Pillage.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end

function Pillage.EffectChanged( _, changeType, _, effectName, unitTag, beginTime, endTime, _, _, _, _, _, _, unitName, unitId, abilityId, _ )
  if abilityId == Pillage.PillagerID then
    if changeType == EFFECT_RESULT_GAINED then
      Pillage.endTime = GetGameTimeMilliseconds()/1000 + GetAbilityDuration(Pillage.CDID)/1000
      Pillage.buffDuration = GetAbilityDuration(Pillage.CDID)/1000
      EVENT_MANAGER:RegisterForUpdate(Pillage.name.."Cycle", 100, Pillage.RefreshUI)
    end
  end
end  

function Pillage.RefreshUI()
  local now = GetGameTimeMilliseconds() / 1000
  local timeRemaining = Pillage.endTime - now
  if(timeRemaining > 0) then
    PillageFrameTime:SetText(string.format("%.1f", timeRemaining))
    PillageFrameTime:SetColor(unpack(Pillage.COLORS.DOWN))
    else
    PillageFrameTime:SetText("0.0")
    PillageFrameTime:SetColor(unpack(Pillage.COLORS.UP))
    EVENT_MANAGER:UnregisterForUpdate(Pillage.name.."Cycle")
  end
end

function Pillage.OnAddOnLoaded( event, addonName )
  if addonName ~= Pillage.name then return end
  EVENT_MANAGER:UnregisterForEvent(Pillage.name, EVENT_ADD_ON_LOADED, Pillage.OnAddOnLoaded)

  Pillage.savedVars = ZO_SavedVars:NewAccountWide("PillageSavedVars", 1, nil, Pillage.defaults, GetWorldName())

  Pillage:Initialize()
end



EVENT_MANAGER:RegisterForEvent(Pillage.name, EVENT_ADD_ON_LOADED, Pillage.OnAddOnLoaded)
