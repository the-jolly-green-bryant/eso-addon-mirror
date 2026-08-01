RandomDungeonTimerCountdown = {}
RandomDungeonTimerCountdown.name = "RandomDungeonTimerCountdown"

function RandomDungeonTimerCountdown:RestorePosition()
  local left = RandomDungeonTimerCountdown.savedVariables.left
  local top = RandomDungeonTimerCountdown.savedVariables.top
  RandomDungeonTimerCountdownUI:ClearAnchors()
  RandomDungeonTimerCountdownUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  RandomDungeonTimerCountdownUI:SetHidden(not RandomDungeonTimerCountdown.savedVariablesChar.enabled)
end

function RandomDungeonTimerCountdown:Initialize()
  self.savedVariables = ZO_SavedVars:NewAccountWide("RandomDungeonTimerCountdownSavedVariables", 1, nil, {})
  self.savedVariablesChar = ZO_SavedVars:NewCharacterIdSettings("RandomDungeonTimerCountdownSavedVariablesChar", 1, nil, {enabled = true})
  self.RestorePosition()
  RandomDungeonTimerCountdownTimeRemaining()
end

function RandomDungeonTimerCountdownTimeRemaining()


	--if (addonName ~= "RandomDungeonTimerCountdown") then return end
	
	--EVENT_MANAGER:UnregisterForEvent("RandomDungeonTimerCountdown", EVENT_ADD_ON_LOADED)
	--SLASH_COMMANDS["/rdt"] = function ()
	
	local timeRemaining = GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_DUNGEON_REWARD_GRANTED)
	
	if timeRemaining == 0 then
		--CHAT_ROUTER:AddSystemMessage("Random dungeon daily reward is available.")
		RandomDungeonTimerCountdownUILabel:SetColor(0, 1, 0)
		RandomDungeonTimerCountdownUILabel:SetText("Random dungeon daily reward is available now!")
			
	else
		local hoursRemaining = math.floor(timeRemaining / 3600)
		local minutesRemaining = math.floor((timeRemaining - hoursRemaining * 3600) / 60)
		if hoursRemaining > 1 then
			RandomDungeonTimerCountdownUILabel:SetColor(1, 0, 0)
		else
			RandomDungeonTimerCountdownUILabel:SetColor(1, 1, 0)
		end
		
		
		--CHAT_ROUTER:AddSystemMessage(string.format("Random dungeon daily reward will be available in %dh %.2dm.", hoursRemaining, minutesRemaining))
		RandomDungeonTimerCountdownUILabel:SetText(string.format("Random dungeon daily reward will be available in %dh %.2dm.", hoursRemaining, minutesRemaining))
		end
	


    if RandomDungeonTimerCountdown.savedVariablesChar.enabled then
      zo_callLater(function()RandomDungeonTimerCountdownTimeRemaining()end,500)
    end
end

function RandomDungeonTimerCountdown.OnAddOnLoaded(event, addonName)
  if addonName == RandomDungeonTimerCountdown.name then
    RandomDungeonTimerCountdown:Initialize()
  end
end

function RandomDungeonTimerCountdown.OnMoveStopUI()
  RandomDungeonTimerCountdown.savedVariables.left = RandomDungeonTimerCountdownUI:GetLeft()
  RandomDungeonTimerCountdown.savedVariables.top = RandomDungeonTimerCountdownUI:GetTop()
end

SLASH_COMMANDS["/rdtc"] = function (optionDisable)
  optionDisable = optionDisable:lower()
  if optionDisable == "off" then
    RandomDungeonTimerCountdown.savedVariablesChar.enabled = false
    d("RandomDungeonTimerCountdown is now disabled")
    RandomDungeonTimerCountdownUI:SetHidden(true)
  elseif optionDisable == "on" then
    RandomDungeonTimerCountdown.savedVariablesChar.enabled = true
    d("RandomDungeonTimerCountdown is now enabled")
    RandomDungeonTimerCountdownUI:SetHidden(false)
    RandomDungeonTimerCountdownTimeRemaining()
  else
    d("/rdtc on - to turn on RDTC reminder")
    d("/rdtc off - to turn off RDTC reminder")
    if RandomDungeonTimerCountdown.savedVariablesChar.enabled then
      d("RandomDungeonTimerCountdown is currently ON")
    else
      d("RandomDungeonTimerCountdown is currently OFF")
    end
  end
end

EVENT_MANAGER:RegisterForEvent(RandomDungeonTimerCountdown.name, EVENT_ADD_ON_LOADED, RandomDungeonTimerCountdown.OnAddOnLoaded)
