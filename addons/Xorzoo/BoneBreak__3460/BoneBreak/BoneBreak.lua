BoneBreak = {}
 
BoneBreak.name = "BoneBreak"
BoneBreak.version = "0.0.2"
BoneBreak.url = "https://www.esoui.com/downloads/info3460-BoneBreak.html"
BoneBreak.playerName = GetRawUnitName("player")
BoneBreak.rootTipType = 19
BoneBreak.stunTipType = 18
BoneBreak.blockTipType = 1

local debugging = true

function dd(msg)
	d("[" .. BoneBreak.name .. "]: " .. msg)
end

function ddd(msg)
	if debugging then
		dd(msg)
	end
end
  
function BoneBreak:Initialize()
  	self.inStun = IsPlayerStunned("player")
	if IsPlayerMoving("player") and IsPlayerTryingToMove("player") then
		self.inRoot = false
	end
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_STUNNED_STATE_CHANGED, self.OnPlayerStunStateChange)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, self.OnCombatEvent)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DISPLAY_ACTIVE_COMBAT_TIP, self.OnTipDisplay)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_REMOVE_ACTIVE_COMBAT_TIP, self.OnTipRemove)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, self.OnBarChanged)
end

function BoneBreak.OnBarChanged(eventCode, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
	if didActiveHotbarChange and not shouldUpdateAbilityAssignments then
		if activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY then
			PrimaryIndicator:SetHidden(false)
			BackupIndicator:SetHidden(true)
		elseif activeHotbarCategory == HOTBAR_CATEGORY_BACKUP then
			PrimaryIndicator:SetHidden(true)
			BackupIndicator:SetHidden(false)
		end
	end
end

function BoneBreak.OnAddOnLoaded(event, addonName)
  if addonName == BoneBreak.name then
    BoneBreak:Initialize()
  end
end
 
 function BoneBreak.OnPlayerStunStateChange(event, stunState)
	if stunState ~= BoneBreak.inStun then
		dd("[STUN]: " .. tostring(stunState))
		BoneBreak.inStun = stunState
		StunIndicator:SetHidden(not stunState)
	end
end

function BoneBreak.OnCombatEvent(_,result,_,_,_,_,_,_,targetName)
	if targetName == BoneBreak.playerName then 
		if result == ACTION_RESULT_FEARED then
			BoneBreak.inFear = true
			if not BoneBreak.inStun then
				dd("[FEAR]: true")
				StunIndicator:SetHidden(false)
			end
		end
	end
end

function BoneBreak.OnTipDisplay(event, tipType)
	isRootTip = false
	if tipType == BoneBreak.rootTipType then 
		dd("[ROOT]: true | " .. tostring(tipType))		
		BoneBreak.inRoot = true
		RootIndicator:SetHidden(false)
	else
		-- dd("OnTipDisplay: " .. tostring(tipType))	
	end
end

function BoneBreak.OnTipRemove(event, tipType, result)
	if tipType == BoneBreak.rootTipType then
		dd("[ROOT]: false | " .. tostring(tipType))
		BoneBreak.inRoot = false
		RootIndicator:SetHidden(true)
	else
		-- dd("OnTipRemove: " .. tostring(tipType))
	end
end

EVENT_MANAGER:RegisterForEvent(BoneBreak.name, EVENT_ADD_ON_LOADED, BoneBreak.OnAddOnLoaded)