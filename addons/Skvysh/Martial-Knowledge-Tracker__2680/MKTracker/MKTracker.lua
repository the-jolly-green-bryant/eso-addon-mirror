MKTracker = {
	name = "MKTracker",
	version = "1.7.1",
	varVersion = 1,
	uiLocked = true,
  MKSet = "|H1:item:95504:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1000:0|h|h", -- some MK item to get set info
  downTime = 0, -- Proc cooldown timer
  debuffTime = 0, -- Global debuff timer when using global debuff tracking
  procAvailable = true,
  -- Default setting values
  defaults		= {
    ["panelCenterX"] = 500,
    ["panelCenterY"] = 500,
    ["procFontSize"] = 60,
    ["stamFontSize"] = 40,
    ["passiveHide"] = false,
    ["showStamina"] = true,
    ["gearCheck"] = true,
    ["offbarCheck"] = false,
    ["procGroupTracker"] = false,
    ["procCooldownType"] = true,
    ["updateInterval"] = 100,
    ["colours"]		= {
      ["up"] = {
      0.0470588244, 1, 0.1137254909, 1
      },
      ["down"] = {
        1, 0, 0,
      },
      ["aboveThreshold"] = {
        1, 0.5882353187, 0, 1
      },
      ["belowThreshold"] = {
        0, 1, 0.9960784316, 1
      },
    },
  },
}

local MKT = MKTracker
local EM = EVENT_MANAGER

-- Check if the player's wearing at least 5 pieces of MK
function MKT.MKCheck()
  if MKT.savedVars.gearCheck then
    local mk = 0
    _,_,_,mk = GetItemLinkSetInfo(MKT.MKSet, true)
    if mk < 3 then return false end
    if (mk >= 3) then return true end
  end
	return true
end

-- Check if the player's on an offbar where MK isn't active, but assume that they have enough pieces to have full set on the other bar
function MKT.MKOffbarCheck()
  if MKT.savedVars.offbarCheck then
    local mk = 0
    _,_,_,mk = GetItemLinkSetInfo(MKT.MKSet, true)
    if mk > 2 and mk < 5 then return true else return false end
  end
	return false
end

-- Check if MK is procced by you on any target
function MKT.Proc(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
  if MKT.MKCheck() then
    MKT.active = false
    MKT.downTime = GetGameTimeMilliseconds()/1000 + 8
    EM:RegisterForUpdate(MKT.name.."Update",  MKT.savedVars.updateInterval, MKT.Countdown)
  end
end

-- Check for proc by anyone in the group on any target
function MKT.GlobalProc(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
  if MKT.MKCheck() then
    MKT.active = false
    MKT.debuffTime = GetGameTimeMilliseconds()/1000 + 5
    EM:RegisterForUpdate(MKT.name.."GlobalUpdate",  MKT.savedVars.updateInterval, MKT.GlobalCountdown)
  end
end

-- Update stamina value
function MKT.Tick()
  if MKT.savedVars.showStamina then
    MKT.GetStam()
  end
end

-- Move status panel
function MKT.Move()
	MKT.savedVars.panelCenterX, MKT.savedVars.panelCenterY = MKTrackerPanel:GetCenter()
	MKTrackerPanel:ClearAnchors()
	MKTrackerPanel:SetAnchor(CENTER, GuiRoot, TOPLEFT, MKT.savedVars.panelCenterX, MKT.savedVars.panelCenterY)
end

-- Load status panel location
function MKT.RestorePosition()
	local panelCenterX = MKT.savedVars.panelCenterX
	local panelCenterY = MKT.savedVars.panelCenterY
	if panelCenterX or panelCenterY then
		MKTrackerPanel:ClearAnchors()
		MKTrackerPanel:SetAnchor(CENTER, GuiRoot, TOPLEFT, panelCenterX, panelCenterY)
	end
end

-- Check if player is in combat
function MKT.CombatState()
	MKT.HideOutOfCombat()
end

-- Hide status panel out of combat if chosen to do so
function MKT.HideOutOfCombat()
  if MKT.MKCheck() then
    if MKT.savedVars.passiveHide then 
      MKT.HidePanel(not IsUnitInCombat("player"))
    end
  end
end

-- Hide status panel if opening menus, etc.
function MKT.HideFrame()
  if MKT.MKCheck() then
    MKT.HidePanel(IsReticleHidden())
  else
    MKT.HidePanel(true)
  end
	if not IsReticleHidden() then MKT.HideOutOfCombat() end
end

-- Call for panel hiding if needed
function MKT.HidePanel(value)
  MKT.BarSwap()
  MKTrackerPanel:SetHidden(value)
  if not value then
    if not MKT.savedVars.showStamina then
      MKT.HideStaminaPanel(not value)
    end
    EM:RegisterForUpdate(MKT.name .. "UpdateStam", MKT.savedVars.updateInterval, MKT.Tick)
  else
    EM:UnregisterForUpdate(MKT.name .. "UpdateStam")
  end
end

-- Hide stamina part of the status panel
function MKT.HideStaminaPanel(value)
  MKTrackerPanel_Stam:SetHidden(value)
end

-- Hide global MK debuff timer part of the panel
function MKT.HideGlobalProcPanel(value)
  MKTrackerPanel_GlobalProc:SetHidden(value)
end

-- Update proc Timer
function MKT.Countdown()
  local procThreshold = 0
  -- Define proc threshold based on settings - 5 or 8 seconds
  if MKT.savedVars.procCooldownType then procThreshold = 0 else procThreshold = 3 end
  -- Check whether we're past the threshold and change the colour appropriately
  if (MKT.downTime - GetGameTimeMilliseconds()/1000 > procThreshold) then
    MKT.SetProcColourDown()
    MKT.procAvailable = false
  else
    MKT.SetProcColourUp()
    MKT.procAvailable = true
  end
  MKTrackerPanel_Proc:SetText(string.format("%.1f",  MKT.Time(MKT.downTime, 1000/MKT.savedVars.updateInterval)))
	if (MKT.downTime - GetGameTimeMilliseconds()/1000 <= 0) then 
		MKTrackerPanel_Proc:SetText("0")
		EM:UnregisterForUpdate(MKT.name.."Update")
	end
end

-- Update global debuff timer
function MKT.GlobalCountdown()
  if (MKT.debuffTime - GetGameTimeMilliseconds()/1000 > 0) then
    MKTrackerPanel_GlobalProc:SetColor(unpack(MKT.savedVars.colours.downGlobal))
    MKTrackerPanel_GlobalProc:SetText(string.format("%.1f",  MKT.Time(MKT.debuffTime, 1000/MKT.savedVars.updateInterval)))
  else
    MKTrackerPanel_GlobalProc:SetColor(unpack(MKT.savedVars.colours.upGlobal))
		MKTrackerPanel_GlobalProc:SetText("0")
		EM:UnregisterForUpdate(MKT.name.."GlobalUpdate")
	end
end

-- Round down timer
function MKT.Time(nd, multiplier)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * multiplier + 0.5)/multiplier
end

-- Update stamina counter
function MKT.GetStam()
  local s, smax = GetUnitPower('player', POWERTYPE_STAMINA)
	local p = math.floor(100 * s / smax + 0.5)
  local color
  if p < 50 then color = MKTrackerPanel_Stam:SetColor(unpack(MKT.savedVars.colours.belowThreshold))
  else color = MKTrackerPanel_Stam:SetColor(unpack(MKT.savedVars.colours.aboveThreshold)) end
	MKTrackerPanel_Stam:SetText(string.format("%d", p))
end

-- Set colours when updating or loading the panel
function MKT.SetColours()
  MKT.SetProcColourUp()
  MKTrackerPanel_GlobalProc:SetColor(unpack(MKT.savedVars.colours.upGlobal))
	MKTrackerPanel_Stam:SetColor(unpack(MKT.savedVars.colours.aboveThreshold))
end

-- Set fonts
function MKT.SetFontSize()
	MKTrackerPanel_Proc:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', MKT.savedVars.procFontSize, 'soft-shadow-thick'))
  MKTrackerPanel_GlobalProc:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', MKT.savedVars.globalProcFontSize, 'soft-shadow-thick'))
  MKTrackerPanel_Stam:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', MKT.savedVars.stamFontSize, 'soft-shadow-thick'))
end

-- Activate events for global debuff tracking
function MKT.RegisterProcEventType()
  EM:UnregisterForUpdate(MKT.name.."Proc")
  EM:UnregisterForUpdate(MKT.name.."GlobalProc")
  local procEvent = MKT.name.."Proc"
	EM:RegisterForEvent(procEvent, EVENT_COMBAT_EVENT, MKT.Proc)
	EM:AddFilterForEvent(procEvent, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 127070)
	EM:AddFilterForEvent(procEvent, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
  EM:AddFilterForEvent(procEvent, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
  if MKT.savedVars.procGroupTracker then
    local globalProcEvent = MKT.name.."GlobalProc"
    EM:RegisterForEvent(globalProcEvent, EVENT_COMBAT_EVENT, MKT.GlobalProc)
    EM:AddFilterForEvent(globalProcEvent, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 127070)
    EM:AddFilterForEvent(globalProcEvent, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    MKT.HideGlobalProcPanel(false)
  else
    MKT.HideGlobalProcPanel(true)
  end
end

-- Update saved variables without deleting old ones
function MKT.AddNewVariables()
  if MKT.savedVars.procGroupTracker == nil then MKT.savedVars.procGroupTracker = false end
  if MKT.savedVars.colours.upGlobal == nil then MKT.savedVars.colours.upGlobal = {} MKT.savedVars.colours.upGlobal = {0.0470588244, 1, 0.1137254909, 1} end
  if MKT.savedVars.colours.downGlobal == nil then MKT.savedVars.colours.downGlobal = {} MKT.savedVars.colours.downGlobal = {1, 0.8235294223, 0.1803921610, 1} end
  if MKT.savedVars.globalProcFontSize == nil then MKT.savedVars.globalProcFontSize = 35 end
  if MKT.savedVars.offbarCheck == nil then MKT.savedVars.offbarCheck = false end
  if MKT.savedVars.colours.upOffbar == nil then MKT.savedVars.colours.upOffbar = {} MKT.savedVars.colours.upOffbar = MKT.savedVars.colours.up end
  if MKT.savedVars.colours.downOffbar == nil then MKT.savedVars.colours.downOffbar = {} MKT.savedVars.colours.downOffbar = MKT.savedVars.colours.down end
end

-- Handle bar swap colour change calls
function MKT.BarSwap()
  if MKT.procAvailable then
    MKT.SetProcColourUp()
  else
    MKT.SetProcColourDown()
  end
end

-- Set the proc colour based on offbar setting when MK is available
function MKT.SetProcColourUp()
  if MKT.MKOffbarCheck() then
    MKTrackerPanel_Proc:SetColor(unpack(MKT.savedVars.colours.upOffbar))
  else
    MKTrackerPanel_Proc:SetColor(unpack(MKT.savedVars.colours.up))
  end
end

-- Set the proc colour based on offbar setting when MK is unavailable
function MKT.SetProcColourDown()
  if MKT.MKOffbarCheck() then
    MKTrackerPanel_Proc:SetColor(unpack(MKT.savedVars.colours.downOffbar))
  else
    MKTrackerPanel_Proc:SetColor(unpack(MKT.savedVars.colours.down))
  end
end
  
-- Initialize the addon
function MKT.Init(event, addon)
	if addon ~= MKT.name then return end
	EM:UnregisterForEvent(MKT.name.."Load", EVENT_ADD_ON_LOADED)
  
  --Handle saved settings
  MKT.savedVars = ZO_SavedVars:NewAccountWide("MKTSettings", MKTracker.varVersion, nil, MKTracker.defaults)
  MKT.AddNewVariables()
  
  -- Register MK proc event
  MKT.RegisterProcEventType()
  
  -- Set up remaining parts of the addon
  MKT.RestorePosition()
	MKTrackerPanel:SetHidden(IsReticleHidden())
  MKT.SetColours()
  MKT.SetFontSize()
  MKT.SetupMenu()
  MKT.HideOutOfCombat()
  
  -- Register some more events for minor things
	EM:RegisterForEvent(MKT.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, MKT.HideFrame)                 -- Hiding reticle
	EM:RegisterForEvent(MKT.name.."CombatState", EVENT_PLAYER_COMBAT_STATE,  MKT.CombatState)         -- Entering/leaving combat
  EM:RegisterForEvent(MKT.name.."GearCheck", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,  MKT.HideFrame)    -- Changing gear
  EM:RegisterForEvent(MKT.name.."BarSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED,  MKT.BarSwap)          -- Changing bars
end

EM:RegisterForEvent(MKT.name.."Load", EVENT_ADD_ON_LOADED, MKT.Init)