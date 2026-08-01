LFGAA = {}
LFGAA.name = "LFGAutoAccept"
LFGAA.version = "1.2.019"
LFGAA.Vars = {}
LFGAA.settings = nil

local bEnabled = true
local em = GetEventManager()

function LFGAA.OnAddOnLoaded(event, addonName)
  if addonName == LFGAA.name then --if its us, handle it
	em:UnregisterForEvent(LFGAA.name, EVENT_ADD_ON_LOADED)
    LFGAA:Initialize()
  end
end

function LFGAA:Initialize()
	-- SavedVars Variables
    self.Vars.savedVariablesName = 'LFGAutoAccept_SavedVariables'
    self.Vars.configVersion      = 1
    self.Vars.configNamespace    = 'LFGAA'
	self.Vars.profile            = nil
    self.Vars.configDefaults     = {
        ["configVersion"]        = self.Vars.configVersion,
        ["debug"]                = false,
		["bEnabled"]             = true
    }  
  
	self.settings = ZO_SavedVars:NewAccountWide(
		self.Vars.savedVariablesName,
		self.Vars.configVersion,
		self.Vars.configNamespace,
		self.Vars.configDefaults,
		self.Vars.profile
	)
end 

function LFGAA.OnPlayerActivated()
	em:UnregisterForEvent(LFGAA.name, EVENT_PLAYER_ACTIVATED)
	if LFGAA.settings.bEnabled == true then
		d('|c339FFBLFG Auto Accept is Enabled|r')
	else
		d('|c339FFBLFG Auto Accept is Disabled|r')
	end
end

--accept looking for group ready check notifications
local function OnActivityFinderStatusUpdate(eventCode, status)
	if LFGAA.settings.bEnabled == true then
		if status == ACTIVITY_FINDER_STATUS_READY_CHECK and HasLFGReadyCheckNotification() then
			AcceptLFGReadyCheckNotification()
		end
		if status == ACTIVITY_FINDER_STATUS_IN_PROGRESS then
			d('LFG Activity in Progress')
			PlaySound(SOUNDS.LOCKPICKING_BREAK)
		end
	end
end

--automatically release on battleground death
local function OnDeathFragmentStateChange(oldState, newState)
	if newState == SCENE_FRAGMENT_SHOWING then
		local _, _, _, _, _, _, isBattleGroundDeath = GetDeathInfo()
		if isBattleGroundDeath then
			Release()
		end
	end
end

--display battleground info upon entering the match and play a sound to wake us up
local function OnBattlegroundStateChanged(eventCode,previousState,currentState)
	if LFGAA.settings.bEnabled == true then
		local battlegroundId = GetCurrentBattlegroundId()
		if previousState == 0 then 
			d('|c339FFB -Battleground: '..GetBattlegroundName(battlegroundId)..'-|r')
			PlaySound(SOUNDS.LOCKPICKING_BREAK)
		end
		if currentState == 1 then --joined
		end
		if currentState == 2 then --countdown started
		end
		if currentState == 3 then --started
		end
		if currentState == 4 then --ending
		end
	end
end

function LFGAA.EnableDisable()
	if LFGAA.settings.bEnabled == true then
		LFGAA.settings.bEnabled = false
		d('|c339FFBLFG Auto Accept is Disabled|r')
	else
		LFGAA.settings.bEnabled = true
		d('|c339FFBLFG Auto Accept is Enabled|r')
	end
end

em:RegisterForEvent(LFGAA.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnActivityFinderStatusUpdate)
DEATH_FRAGMENT:RegisterCallback("StateChange", OnDeathFragmentStateChange)
em:RegisterForEvent(LFGAA.name, EVENT_BATTLEGROUND_STATE_CHANGED, OnBattlegroundStateChanged)
em:RegisterForEvent(LFGAA.name, EVENT_ADD_ON_LOADED, LFGAA.OnAddOnLoaded)
em:RegisterForEvent(LFGAA.name, EVENT_PLAYER_ACTIVATED, LFGAA.OnPlayerActivated)