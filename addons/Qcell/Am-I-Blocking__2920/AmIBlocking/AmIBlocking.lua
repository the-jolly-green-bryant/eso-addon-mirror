AmIBlocking = {}

AmIBlocking.name = "AmIBlocking"
AmIBlocking.lockedUI = false

function AmIBlocking:Initialize()
  AmIBlocking.AddonMenu()

  EVENT_MANAGER:RegisterForUpdate(self.name.."TickUpdate", 1000/60, function(gameTimeMs) self.UpdateBlock() end)
  
  self.savedVariables = ZO_SavedVars:New("AmIBlockingSavedVariables", 1, nil, {})

  self.RestorePosition()
  
  AmIBlocking.CallbackManager = ZO_CallbackObject:New()
end

function AmIBlocking.OnAddOnLoaded(event, addonName)
  if addonName == AmIBlocking.name then
    AmIBlocking:Initialize()
  end
end

local old_is_block_active = false
function AmIBlocking.UpdateBlock(gameTimeMs)
  local is_block_active = false
  
  local isRunning = IsShiftKeyDown() and IsPlayerMoving()
  local inCombat = IsUnitInCombat("player")
  local stamReg = 0
  local magReg = 0
  
  if inCombat then
    stamReg = GetPlayerStat(STAT_STAMINA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS)
    magReg = GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS)
  else
    stamReg = GetPlayerStat(STAT_STAMINA_REGEN_IDLE, STAT_BONUS_OPTION_APPLY_BONUS)
    magReg = GetPlayerStat(STAT_MAGICKA_REGEN_IDLE, STAT_BONUS_OPTION_APPLY_BONUS)
  end

  if IsBlockActive() and not isRunning and (stamReg == 0 or magReg == 0) then
    is_block_active = true
  end

  AmIBlockingIndicator:SetHidden(not AmIBlocking.lockedUI and not is_block_active)
  
  if old_is_block_active ~= is_block_active then
    AmIBlocking.CallbackManager:FireCallbacks(AmIBlocking.name .. "BLOCKING_STATE_CHANGE", is_block_active)
    old_is_block_active = is_block_active
  end
end

function AmIBlocking.OnIndicatorMoveStop()
  AmIBlocking.savedVariables.left = AmIBlockingIndicator:GetLeft()
  AmIBlocking.savedVariables.top = AmIBlockingIndicator:GetTop()
end

function AmIBlocking.ResetPosition()
  AmIBlockingIndicator:ClearAnchors()
  AmIBlockingIndicator:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, -40)
  AmIBlocking.OnIndicatorMoveStop()
end

function AmIBlocking.RestorePosition()
  local left = AmIBlocking.savedVariables.left
  local top = AmIBlocking.savedVariables.top
  if (left ~= nil and top ~= nil and left > 0 and top > 0) then
    if AmIBlockingIndicator:GetAnchor() ~= nil then
      AmIBlockingIndicator:ClearAnchors()
    end
    AmIBlockingIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  else
    AmIBlocking.ResetPosition()
  end
end

function AmIBlocking.AddonMenu()
	local menuOptions = {
		type				 = "panel",
		name				 = AmIBlocking.name,
		displayName	 = AmIBlocking.name,
		author			 = AmIBlocking.author,
		version			 = AmIBlocking.version,
		slashCommand = "/aib",
		registerForRefresh	= true,
		registerForDefaults = true,
	}

	local dataTable = {
		{
			type = "description",
			text = "Simple. Am I blocking? It shows a visible cue if you are blocking.",
		},
		{
			type = "divider",
		},
		{
			type    = "checkbox",
			name    = "Lock UI (to move it)",
			default = false,
			getFunc = function() return AmIBlocking.lockedUI end,
			setFunc = function( newValue ) AmIBlocking.lockedUI = newValue; end,
		},
    {
			type    = "button",
			name    = "Reset to default position",
			func = function() AmIBlocking.ResetPosition()  end,
		},
	}

	LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(AmIBlocking.name .. "Options", menuOptions )
	LAM:RegisterOptionControls(AmIBlocking.name .. "Options", dataTable )
end


EVENT_MANAGER:RegisterForEvent(AmIBlocking.name, EVENT_ADD_ON_LOADED, AmIBlocking.OnAddOnLoaded)


--[[ Pending features and checks.
-- Check if stam > block cost.
-- Support the 1h&shield ultimate.

-- Additional blocking features: Block when a meteor is cast, on overload in vCR3...
   -- If holding block during a core mechanic, disable things that can break block
    Barswap, channeled. Of course have this as a setting.

--]]
