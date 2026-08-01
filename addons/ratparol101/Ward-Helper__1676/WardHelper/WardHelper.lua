-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
-- WardHelper.Default = {
-- WardHelperOn=true	
-- }
WardHelper={}
WardHelper.name="WardHelper"
WardHelper.version=1.1
--Settings
--function WardHelper.Settings()

--ZO_GameMenu_AddSettingPanel(WardHelper)
--ZO_GameMenu_OnShow("WardHelperOptions")
--ZO_GameMenuManager:AddEntry(WardHelper)

--end
-- These two RestorePosition functions make the WARDUP! and Fighting! return to their places based on where the user put them last
function WardHelper:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
  WardHelperIndicator:ClearAnchors()
  WardHelperIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end
function WardHelper:WardUpRestorePosition()
  local wardleft = self.savedVariables.WardUpleft
  local wardtop = self.savedVariables.WardUpTop
 
  WardHelperWardUp:ClearAnchors()
  WardHelperWardUp:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, wardleft, wardtop)
end
function WardHelper.CreateSettingsWindow()
local panelData = {
	type = "panel",
	name = "Ward Helper",
	displayName = "Ward Helper",
	author = "@Ratparol101",
	version = WardHelper.version,
	slashCommand = "/wardhelper",
	registerForRefresh = true,
	registerForDefaults = false,
}
local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Ward_Helper", panelData)
local optionsData = {
[1] = {
	type = "header",
	name = "Ward Helper",
},
[2] = {
	type = "description",
	text = "What are you doing reading this description",
},
[3] = {
	type = "checkbox",
	name = "Display WARDUP!",
	tooltip = "When ON WARDUP! will remind you to cast your damage shields",
	default = true,
	getFunc = function() return WardHelper.savedVariables.WardHelperOn end,
	setFunc = function(newValue) 
		WardHelper.savedVariables.WardHelperOn = newValue
		WardHelperOn=newValue 
		end,
},
}

LAM2:RegisterOptionControls("Ward_Helper", optionsData)
 
end

function WardHelper:Initialize()


wardstate= false
	
	self.inCombat = IsUnitInCombat("player")
	
	WardHelperIndicator:SetHidden(true)
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYEVENT_UNIT_DEATH_STATE_CHANGED, self.OnPlayerDeath)
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, self.OnUnitAttributeVisualRemoved)
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, self.OnUnitAttributeVisualAdded)
	
	--EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED, self.OnDeathState)
	
	self.savedVariables = ZO_SavedVars:New("WardHelperSavedVariables", 1, nil, {})
	
	WardHelper.CreateSettingsWindow()
	
	WardHelper:RestorePosition()
	
	WardHelperWardUp:SetHidden(true)
	
	--WardHelper.Settings()
	
end
-- function WardHelper:UpdateSlots()
-- WardHelperSlot1= GetSlotName(3)
-- WardHelperSlot2= GetSlotName(4)
-- WardHelperSlot3= GetSlotName(5)
-- WardHelperSlot4= GetSlotName(6)
-- WardHelperSlot5= GetSlotName(7)
-- WardHelperSlot6= GetSlotName(18)
-- WardHelperSlot7= GetSlotName(19)
-- WardHelperSlot8= GetSlotName(20)
-- WardHelperSlot9= GetSlotName(21)
-- WardHelperSlot10= GetSlotName(22)
-- end
function WardHelper.OnAddOnLoaded(event, addonName)
	if addonName == WardHelper.name then
		WardHelper:Initialize()
	
		end
	end
EVENT_MANAGER:RegisterForEvent(WardHelper.name, EVENT_ADD_ON_LOADED, WardHelper.OnAddOnLoaded)
--This function will display WARDUP! if you are in combat, no damageshield is present, and the /disablewh command has not been used
function WardHelper.OnUnitAttributeVisualRemoved(event)
--
--wardstate= false
local WardHelperOn= WardHelper.savedVariables.WardHelperOn
if IsUnitDead("player")==false and IsUnitInCombat("player") and WardHelperOn ~=false and GetUnitAttributeVisualizerEffectInfo("player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH) ==nil  then
  WardHelperWardUp:SetHidden(false)
  --@jrodriquez is a guild who forgets his wards alot; This message is just for him :)
  --Removed in version 1.1
  --if GetUnitDisplayName('player') == "@jrodriguez" then
  --d("IF YOU DIE ITS CAUASE YOU DID NOT WARD UP!")
   --end
   end
   end
   function WardHelper.OnPlayerDeath(event)
   local deathstate= IsUnitDead("player")
   if deathstate then
   WardHelperWardUp:SetHidden(true)
   end
   if deathstate ==false and IsUnitInCombat("player") and WardHelperOn ~=false and GetUnitAttributeVisualizerEffectInfo("player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH) ==nil  then
   WardHelperWardUp:SetHidden(false)
   end
   end
   -- function WardHelper.OnDeathState(event, deathState)
   -- if GetUnitAttributeVisualizerEffectInfo("player",ATTRIBUTE_VISUAL_NONE,STAT_NONE,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH)
   -- WardHelperWardUp:SetHidden(true)
   
   -- --deathstate= true
   --end
   function WardHelper.OnUnitAttributeVisualAdded(event)
   --This function hides the WARDUP! when a player gets a damageshield
   --d(GetUnitAttributeVisualizerEffectInfo("player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH)) 
  if GetUnitAttributeVisualizerEffectInfo("player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH) ~=nil then
  WardHelperWardUp:SetHidden(true)
  end
	end
  
   

--This function is very similar to the one on the ESO WIKI writing your first addon guide
--This function will show the FIGHTING! text when a user enters combat and hide it when they leave combat
--This function also enables WARDUP! if /disablewh has not been used and a damageshield is not up
function WardHelper.OnPlayerCombatState(event, inCombat)
local WardHelperOn= WardHelper.savedVariables.WardHelperOn
  if inCombat ~= WardHelper.inCombat then
  --d(GetAllUnitAttributeVisualizerEffectInfo("player"))
  if  WardHelperOn ~=false and GetUnitAttributeVisualizerEffectInfo("player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH) ==nil  then
  WardHelperWardUp:SetHidden(false)
  end
    -- The player's state has changed. Update the stored state...
    WardHelper.inCombat = inCombat
	if inCombat then
      d("Entering combat.")
	  WardHelperIndicator:SetHidden(false) 
	  -- IGNORE THIS ,BUT COULD BE USED TO CHECK IF HARDENED WARDIS UP
	  -- i=1
	  -- while i<= GetNumBuffs("player") do
	  -- i= i+1
	  -- FUBITCH ={GetUnitBuffInfo("player", i)}
	 
	  -- if FUBITCH[1]== "Hardened Ward" then
	  -- d("UP")
	  -- WardHelperWardUp:SetHidden(true)
	  
	  -- local counter = FUBITCH[2]- FUBITCH[3]
	  -- while counter >.001 do
	  -- counter= counter -.001
	  -- end
	  -- WardHelperWardUp:SetHidden(false)
	  -- end
    else
      d("Exiting combat.")
	  WardHelperIndicator:SetHidden(true)
	  WardHelperWardUp:SetHidden(true)
    end
 
  end
end
--These to two functions are used to save text locations on screen for next time
--Also note that the two text messages can be dragged
function WardHelper.OnIndicatorMoveStop()
  WardHelper.savedVariables.left = WardHelperIndicator:GetLeft()
  WardHelper.savedVariables.top = WardHelperIndicator:GetTop()
end
function WardHelper.OnWardHelperMoveStop()
  WardHelper.savedVariables.WardUpleft = WardHelperWardUp:GetLeft()
  WardHelper.savedVariables.WardUptop = WardHelperWardUp:GetTop()
end

 
--SLASH COMMANDS
--This one will disable the WARDUP! text
SLASH_COMMANDS["/disablewh"] = function() 
WardHelper.savedVariables.WardHelperOn = false
ReloadUI()
end
--This one will enable the WARDUP! text(by deafult WARDUP! is on)
SLASH_COMMANDS["/enablewh"] = function() 
WardHelper.savedVariables.WardHelperOn = true
ReloadUI()
end
--This one will allow you to reset the positions of FIGHTING and WARDUP! and also renable WARDUP! text
SLASH_COMMANDS["/defaultwh"] = function() 
WardHelper.savedVariables.left= nil
WardHelper.savedVariables.top= nil
WardHelper.savedVariables.WardUpleft= nil
WardHelper.savedVariables.WardHelperOn= nil
WardHelper.savedVariables.WardUpleft=nil
ReloadUI()
end
--This toggles FIGHTING! and WARDUP! regaurdless of combat state/ward state so you can adjust the locations of the messages
SLASH_COMMANDS["/showwh"] = function() 
WardHelperIndicator:ToggleHidden()
WardHelperWardUp:ToggleHidden()
end
