
local ApplyTemplateToControl = ApplyTemplateToControl
local GetControl = GetControl
local Gsub = string.gsub

-----------------------------------------------------------
-- Dynamic Templates
-----------------------------------------------------------

local HasAlt =
{ ZO_TrackedHeader  = true
, ZO_QuestCondition = true
, ZO_AlertLine      = true }

-- Skin Dynamically Created Elements
SecurePostHook('CreateControlFromVirtual', function(name, _, template, suffix) 
  if HasAlt[template] then 
    local control  = GetControl(name, suffix)
    local template = Gsub(template, 'ZO_', 'ALT_')
    ApplyTemplateToControl(control, template)
  end
end)

-----------------------------------------------------------
-- HUD: Reticle
-----------------------------------------------------------

-- Remove Interact Button Icon
ZO_ReticleContainerInteractKeybindButtonNameLabel:SetParent(ZO_ReticleContainerInteract)

ApplyTemplateToControl(ZO_ReticleContainer, 'ALT_Reticle')

-- Change Stealth Text Font ('HIDDEN')
ZO_ReticleContainerStealthIconStealthText:SetFont('AltFontMediumHUD')

-- Disable Reticle Heavy Attcack Change
-- ingame / reticle / reticle.lua
ZO_ReticleContainer:UnregisterForEvent(EVENT_IMPACTFUL_HIT)

-----------------------------------------------------------
-- HUD: Compass
-----------------------------------------------------------

ApplyTemplateToControl(ZO_CompassFrame, 'ALT_CompassFrame')
ApplyTemplateToControl(ZO_Compass,      'ALT_Compass')

-- Don't Rezize Compass
ZO_CompassFrame:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
ZO_CompassFrame:UnregisterForEvent(EVENT_SCREEN_RESIZED)

-- Set N,S,E,W Font
COMPASS:SetCardinalDirections('AltFontMedium')

-- Don't Resize Compass Height
function COMPASS_FRAME:SetBossBarActive (active)
  self.bossBarActive = active
  self:RefreshVisible()
end

-- Change Compass Quest Area Opacity
-- ingame / compass / compassframe.lua
do local Original = Compass.ApplyTemplateToControlToAreaTexture
  function Compass:ApplyTemplateToControlToAreaTexture(texture, template, restingAlpha, pinType)
    return Original(self, texture, template, 0.5, pinType) -- Set to 50%
  end
end

-----------------------------------------------------------
-- HUD: Attribute Bars
-----------------------------------------------------------

ApplyTemplateToControl(ZO_PlayerAttribute, 'ALT_PlayerAttribute')

-- Disable Health Bar Unwavering Effect
-- esoui / ingame / unitattributevisualizer / modules / unwavering.lua
function ZO_UnitVisualizer_UnwaveringModule:InitializeBarValues () return end

-- Disable Health Bar Armor Effects
-- esoui / ingame / unitattributevisualizer / modules / armordamage.lua
function ZO_UnitVisualizer_ArmorDamage:InitializeBarValues () return end

-- Use Custom Template for Health Bar Shields
-- ingame / unitattributevisualizer / modules / powersield.lua
SecurePostHook(ZO_UnitVisualizer_PowerShieldModule, 'ShowOverlay', function(_, _, info) 
  ApplyTemplateToControl(info.overlayControls[1], 'ALT_PowerShieldBar')
  ApplyTemplateToControl(info.overlayControls[2], 'ALT_PowerShieldBar')
end)

-----------------------------------------------------------
-- HUD: Action Bar
-----------------------------------------------------------

ApplyTemplateToControl(ZO_ActionBar1, 'ALT_ActionBar1')

-- Use Custom Template For Action Slots
-- ingame / actionbar / actionbutton.lua
SecurePostHook(ActionButton, 'ApplyStyle', function(self) 
  ApplyTemplateToControl(self.slot, 'ALT_ActionButton')
end)

-----------------------------------------------------------
-- HUD: Meters
-----------------------------------------------------------

ApplyTemplateToControl(ZO_HUDInfamyMeter, 'ALT_HUDInfamyMeter')
ApplyTemplateToControl(ZO_PerformanceMeters, 'ALT_PerformanceMeters')

-----------------------------------------------------------
-- HUD: Alert Messages
-----------------------------------------------------------

-- Position Alterts
do local anchor = ALERT_MESSAGES.alerts.anchor
  anchor:SetMyPoint(TOPRIGHT)
  anchor:SetOffsets(-40, 20)
end

-----------------------------------------------------------
-- HUD: Quest Tracker
-----------------------------------------------------------

ApplyTemplateToControl(ZO_FocusedQuestTrackerPanel, 'ALT_FocusedQuestTrackerPanel')
ApplyTemplateToControl(ZO_ActivityTracker, 'ALT_ActivityTracker')

-- Remove Indents
FOCUSED_QUEST_TRACKER.treeView:SetIndent(0)
SecurePostHook(ACTIVITY_TRACKER, "InitializeStyles", function() 
  ACTIVITY_TRACKER.styles.keyboard.SUBLABEL_SECONDARY_ANCHOR:SetOffsets(0, 0)
  ACTIVITY_TRACKER.styles.keyboard.CONTAINER_SECONDARY_ANCHOR:SetOffsets(-40)
end)

-- Remove Keybind Button
FOCUSED_QUEST_TRACKER.assistedTexture:SetParent(GuiRoot)

-- Don't Modify Styles In Code
FOCUSED_QUEST_TRACKER.headerPool:SetCustomAcquireBehavior()
FOCUSED_QUEST_TRACKER.conditionPool:SetCustomAcquireBehavior()
FOCUSED_QUEST_TRACKER.stepDescriptionPool:SetCustomAcquireBehavior()

-----------------------------------------------------------
-- HUD: Unit Frames
-----------------------------------------------------------

ApplyTemplateToControl(ZO_BossBar, 'ALT_BossBar')

-- Target Unit Frame
CALLBACK_MANAGER:RegisterCallback('UnitFramesCreated', function() 
  ZO_TargetUnitFramereticleoverRightBracket:SetParent(GuiRoot)
  ZO_TargetUnitFramereticleoverLeftBracket:SetParent(GuiRoot)
  ApplyTemplateToControl(ZO_TargetUnitFramereticleover, 'ALT_TargetUnitFrame')
end)

-----------------------------------------------------------
-- HUD: Chat Window
-----------------------------------------------------------

-- Disable Chat Icon Pulse
-- ingame / chatsystem / pc / chatsystem.lua
function ZO_ChatSystem:SetupNotifications (numNotifications)
  self.notificationsLabel:SetText(numNotifications)
end
