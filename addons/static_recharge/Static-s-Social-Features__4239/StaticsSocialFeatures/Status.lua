--[[------------------------------------------------------------------------------------------------
Title:          Status
Author:         Static_Recharge
Description:    Controls the AFK and Offline timer and features
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local EM = EVENT_MANAGER


--[[------------------------------------------------------------------------------------------------
Status Class Initialization
Status    													              - Parent object containing all functions, tables, variables, constants and other data managers.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ :PlayerIdle()															    - Checks if the player is idle and updates the timer accordingly.
├─ :StartAFKTimerAgain()                					- Used to re-enable the afk timer from external code
├─ :OfflineTimerUpdate()               						- Checks if the offline timer end has been reached if enabled.
├─ :OnPlayerActivated(eventCode, initial)					- Fired when the player character is available after loading screens such as changing 
│                                                   zones, reloadui and logging in. Sets the desired player Status for the logged in
│                                                   character, if not disabled.
├─ :OnEventChatMessageChannel(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
│                                     						- Fired when there is a chat message. Checking for outgoing whispers and notifying if needed.
└─ :GetParent()                                   - Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
local Status = {}


--[[------------------------------------------------------------------------------------------------
Status:Initialize(Parent)
Inputs:				Parent 					- The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function Status:Initialize(Parent)
  self.Parent = Parent
  self.afkEventSpace = "SSFAFKTimer"
  self.offlineEventSpace = "SSFOfflineTimer"
  self.eventSpace = "SSFStatus"
  self.updateInterval = 1000 -- ms
  self.afkAccumulator = 0 -- s

  local afkEnabled = Parent.SV.afkTimerEnabled
  local offlineEnabled = Parent.SV.offlineTimerEnabled

  if afkEnabled then
    EM:RegisterForUpdate(self.afkEventSpace, self.updateInterval, function() self:PlayerIdle() end)
  end

  if offlineEnabled then
    -- wait for character to load in before timing
    EM:RegisterForEvent(self.offlineEventSpace, EVENT_PLAYER_ACTIVATED, function(eventCode, initial)
      if initial then
        Parent.SV.offlineTimerEnd = os.clock() + (Parent.SV.offlineTimeout * 60)
      end
      EM:RegisterForUpdate(self.offlineEventSpace, self.updateInterval, function() self:OfflineTimerUpdate() end)
      EM:UnregisterForEvent(self.offlineEventSpace, EVENT_PLAYER_ACTIVATED)
    end)
  end

  EM:RegisterForEvent(self.eventSpace, EVENT_PLAYER_ACTIVATED, function(...) self:OnPlayerActivated(...) end)
  EM:RegisterForEvent(self.eventSpace, EVENT_CHAT_MESSAGE_CHANNEL, function(...) self:OnEventChatMessageChannel(...) end)

  self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
Status:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function Status:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
Status:PlayerIdle()
Inputs:				None  
Outputs:			None
Description:	Checks if the player is idle and updates the timer accordingly.
------------------------------------------------------------------------------------------------]]--
function Status:PlayerIdle()
  local Parent = self:GetParent()
  local afkEnabled = Parent.SV.afkTimerEnabled
  local afkNotice = Parent.SV.afkNotice
  -- Unregister timer and quit if setting changed since last update.
  if not afkEnabled then
    self.afkAccumulator = 0
    EM:UnregisterForUpdate(self.afkEventSpace)
    return
  end

  -- if even one of these evaluate to true then the player is busy.
  -- All have to be false for the player to be idle
	if (not ArePlayerWeaponsSheathed())
		or GetInteractionType() ~= 0
		or GetUnitStealthState("player") ~= 0
		or IsBlockActive()
		or (IsGameCameraUIModeActive() and DoesGameHaveFocus())
		or IsInteracting()
		or IsInteractionPending()
		or IsLooting()
		or IsMounted()
		or IsPlayerInteractingWithObject()
		or IsPlayerMoving()
		or IsPlayerStunned()
		or IsPlayerTryingToMove()
		or IsUnitDeadOrReincarnating("player")
		or IsUnitInCombat("player")
		or IsUnitSwimming("player")
	then
		self.afkAccumulator = 0
    if GetPlayerStatus() == Parent.PlayerStatus.Away then
      SelectPlayerStatus(Parent.PlayerStatus.Online)
      if afkNotice then Parent.Notifications:Notify("Switched to Online.") end
    end
  else
    self.afkAccumulator = self.afkAccumulator + 1
    if self.afkAccumulator >= Parent.SV.afkTimeout and GetPlayerStatus() == Parent.PlayerStatus.Online then
      SelectPlayerStatus(Parent.PlayerStatus.Away)
      if afkNotice then Parent.Notifications:Notify("Switched to AFK.") end
    end
  end
end


--[[------------------------------------------------------------------------------------------------
Status:StartAFKTimerAgain()
Inputs:				None
Outputs:			None
Description:	Used to re-enable the afk timer from external code
------------------------------------------------------------------------------------------------]]--
function Status:StartAFKTimerAgain()
  self.afkAccumulator = 0
  EM:RegisterForUpdate(self.afkEventSpace, self.updateInterval, function() self:PlayerIdle() end)
end


--[[------------------------------------------------------------------------------------------------
Status:OfflineTimerUpdate()
Inputs:				None  
Outputs:			None
Description:	Checks if the offline timer end has been reached if enabled.
------------------------------------------------------------------------------------------------]]--
function Status:OfflineTimerUpdate()
  local time = os.clock()
  local Parent = self:GetParent()
  local offlineEnabled = Parent.SV.offlineTimerEnabled
  -- unregister if they already switched to online or if they disabled it.
  if not offlineEnabled or GetPlayerStatus() == Parent.PlayerStatus.Online then
    EM:UnregisterForUpdate(self.offlineEventSpace)
  end
  if time >= Parent.SV.offlineTimerEnd and GetPlayerStatus() == Parent.PlayerStatus.Offline then    
    SelectPlayerStatus(Parent.PlayerStatus.Online)
    if Parent.SV.offlineTimerNotice then Parent.Notifications:Notify("Automatically set to Online.") end
  end
end


--[[------------------------------------------------------------------------------------------------
Status:OnPlayerActivated(eventCode, initial)
Inputs:				eventCode				- Internal ZOS event code, not used here.
							initial					- Indicates if this is the first activation from log-in.
Outputs:			None
Description:	Fired when the player character is available after loading screens such as changing 
							zones, reloadui and logging in. Sets the desired player Status for the logged in
							character, if not disabled.
------------------------------------------------------------------------------------------------]]--
function Status:OnPlayerActivated(eventCode, initial)
  local Parent = self:GetParent()
	Parent.Chat:Debug("OnPlayerActivated event fired.")
	Parent.Chat:Debug(zo_strformat("Player Status is <<1>>", GetPlayerStatus()))
	if initial then
		if Parent.initialized then Parent.Chat:Debug("Initialized.") end
		local i = Parent:GetCharacterIndex()
		Parent.Chat:Debug(zo_strformat("Character \"<<1>>\" (<<2>>) loaded.", Parent.SV.Characters[i].name, Parent.SV.Characters[i].id))
		if Parent.SV.accountOverrideEnabled and Parent.SV.accountOverrideLogin then
			SelectPlayerStatus(Parent.SV.accountOverride)
			Parent.Chat:Debug(zo_strformat("Player Status set to <<1>>", Parent.SV.accountOverride))
		elseif
			Parent.SV.Characters[i].charOverride ~= Parent.PlayerStatus.Disabled and Parent.SV.Characters[i].charOverrideLogin then
			SelectPlayerStatus(Parent.SV.Characters[i].charOverride)
			Parent.Chat:Debug(zo_strformat("Player Status set to <<1>>", Parent.SV.Characters[i].charOverride))
		end
		if Parent.SV.offlineNotice and GetPlayerStatus() == Parent.PlayerStatus.Offline then
			Parent.Notifications:Notify("You are set to offline.")
		end
	end
	EM:UnregisterForEvent(self.eventSpace, EVENT_PLAYER_ACTIVATED)
end


--[[------------------------------------------------------------------------------------------------
Status:OnEventChatMessageChannel(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
Inputs:				eventCode				- Internal ZOS event code, not used here.
							channelType			- Global Constant channelType (using CHAT_CHANNEL_WHISPER_SENT)
							fromName  			- Character name of the sender
							text 						- body of the message
							isCustomerService- boolean if the message is from customer service
							fromDisplayName	- @name of the sender
Outputs:			None
Description:	Fired when there is a chat message. Checking for outgoing whispers and notifying if
							needed.
------------------------------------------------------------------------------------------------]]--
function Status:OnEventChatMessageChannel(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
  local Parent = self:GetParent()
	if channelType ~= CHAT_CHANNEL_WHISPER_SENT then return end
	Parent.Chat:Debug("OnEventChatMessageChannel event fired.")
	if GetPlayerStatus() == Parent.PlayerStatus.Offline and Parent.SV.whisperNotice then
		Parent.Notifications:Notify("You are set to offline and cannot receive replies to whispers.")
	end
end


--[[------------------------------------------------------------------------------------------------
Status:GetParent()
Inputs:				None
Outputs:			Parent          - The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function Status:GetParent()
  return self.Parent
end


--[[------------------------------------------------------------------------------------------------
Global template assignment
------------------------------------------------------------------------------------------------]]--
StaticsSocialFeatures.Status = Status