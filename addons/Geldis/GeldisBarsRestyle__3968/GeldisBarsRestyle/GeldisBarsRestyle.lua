
local ApplyTemplate = ApplyTemplateToControl
local GetControl = GetControl
local Gsub = string.gsub
local EM = EVENT_MANAGER
	
	function TryAutoTrackNextPromotionalEventCampaign() end
	ZO_UnitFramesGroups:SetHidden(true)
	ZO_ChatWindowMinBar:SetAlpha(0)
	ZO_ActionBar1KeybindBG:SetAlpha(0)
	ZO_ActionBar1WeaponSwap:SetAlpha(0)

	RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "GeldisBarsRestyle/abilityframe64_up.dds")
	RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "GeldisBarsRestyle/abilityframe64_up.dds")
	
	RedirectTexture("esoui/art/unitframes/targetunitframe_bracket_level2_left.dds", "GeldisBarsRestyle/targetunitframe_bracket_level2_left.dds")
	RedirectTexture("esoui/art/unitframes/targetunitframe_bracket_level2_right.dds", "GeldisBarsRestyle/targetunitframe_bracket_level2_right.dds")
	RedirectTexture("esoui/art/unitframes/targetunitframe_bracket_level3_left.dds", "GeldisBarsRestyle/targetunitframe_bracket_level3_left.dds")
	RedirectTexture("esoui/art/unitframes/targetunitframe_bracket_level3_right.dds", "GeldisBarsRestyle/targetunitframe_bracket_level3_right.dds")
	RedirectTexture("esoui/art/unitframes/targetunitframe_bracket_level4_left.dds", "GeldisBarsRestyle/targetunitframe_bracket_level4_left.dds")
	RedirectTexture("esoui/art/unitframes/targetunitframe_bracket_level4_right.dds", "GeldisBarsRestyle/targetunitframe_bracket_level4_right.dds")
	
	RedirectTexture("esoui/art/miscellaneous/interactkeyframe_center.dds", "GeldisBarsRestyle/interactkeyframe_center.dds")
	RedirectTexture("esoui/art/miscellaneous/interactkeyframe_edge.dds", "GeldisBarsRestyle/interactkeyframe_edge.dds")
	
	RedirectTexture("esoui/art/actionbar/abilityframe_buff.dds", "GeldisBarsRestyle/abilityframe_buff.dds")
	RedirectTexture("esoui/art/actionbar/abilityframe_debuff.dds", "GeldisBarsRestyle/abilityframe_debuff.dds")
	
	RedirectTexture("esoui/art/unitattributevisualizer/attributebar_dynamic_fill_gloss.dds", "GeldisBarsRestyle/gloss/attributebar_dynamic_fill_gloss.dds")
	RedirectTexture("esoui/art/unitattributevisualizer/attributebar_dynamic_leadingedge_gloss.dds", "GeldisBarsRestyle/gloss/attributebar_dynamic_leadingedge_gloss.dds")
	RedirectTexture("/esoui/art/unitattributevisualizer/targetbar_dynamic_fill_gloss.dds", "GeldisBarsRestyle/gloss/targetbar_dynamic_fill_gloss.dds")
	RedirectTexture("/esoui/art/unitattributevisualizer/targetbar_dynamic_leadingedge_gloss.dds", "GeldisBarsRestyle/gloss/targetbar_dynamic_leadingedge_gloss.dds")
	RedirectTexture("/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds", "GeldisBarsRestyle/gloss/progressbar_large_genericfill_leadingedge_gloss.dds")
	RedirectTexture("/esoui/art/miscellaneous/progressbar_genericfill_gloss.dds", "GeldisBarsRestyle/gloss/progressbar_large_genericfill_gloss.dds")
	RedirectTexture("esoui/art/unitattributevisualizer/attributebar_small_fill_center_gloss.dds", "GeldisBarsRestyle/gloss/attributebar_small_fill_center_gloss.dds")
	RedirectTexture("esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge_gloss.dds", "GeldisBarsRestyle/gloss/attributebar_small_fill_leadingedge_gloss.dds")

-----------------------------------------------------------
-- HUD: Compass
-----------------------------------------------------------

ApplyTemplateToControl(ZO_CompassFrame, 'ALT_CompassFrame')
ApplyTemplateToControl(ZO_Compass,      'ALT_Compass')

-- Don't Rezize Compass
ZO_CompassFrame:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
ZO_CompassFrame:UnregisterForEvent(EVENT_SCREEN_RESIZED)

-- Don't Resize Compass Height
function COMPASS_FRAME:SetBossBarActive (active)
  self.bossBarActive = active
  self:RefreshVisible()
end

-- Change Compass Quest Area Opacity
-- ingame / compass / compassframe.lua
do local Original = Compass.ApplyTemplateToControlToAreaTexture
  function Compass:ApplyTemplateToControlToAreaTexture(texture, template, restingAlpha, pinType)
    return Original(self, texture, template, 0, pinType) -- Set to 50%
  end
end

-- Permanently hide compass distance strings
local function HideDistanses()
    SafeAddString(SI_COMPASS_PIN_DISTANCE_FORMATTER, "", 1)       -- short distance
    SafeAddString(SI_COMPASS_PIN_LONG_DISTANCE_FORMATTER, "", 1)  -- long distance
end

local function OnAddOnLoaded(_, addonName)
    EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
    HideDistanses()
end

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-----------------------------------------------------------
-- HUD: Unit Frames
-----------------------------------------------------------

ApplyTemplateToControl(ZO_BossBar, 'ALT_BossBar')

-- Target Unit Frame
CALLBACK_MANAGER:RegisterCallback('UnitFramesCreated', function() 
  ApplyTemplateToControl(ZO_TargetUnitFramereticleover, 'ALT_TargetUnitFrame')
end)

-----------------------------------------------------------
-- Attribute Bars
-----------------------------------------------------------

-- Templates
ApplyTemplate(ZO_PlayerAttribute, 'ALT_PlayerAttribute')

-- Disable Health Bar Unwavering Effect
-- esoui / ingame / unitattributevisualizer / modules / unwavering.lua
-- function ZO_UnitVisualizer_UnwaveringModule:InitializeBarValues ()
  -- return
-- end

-- Disable Health Bar Armor Effects
-- esoui / ingame / unitattributevisualizer / modules / armordamage.lua
function ZO_UnitVisualizer_ArmorDamage:InitializeBarValues ()
  return
end

--Use Custom Template for Health Bar Shields
--ingame / unitattributevisualizer / modules / powersield.lua
SecurePostHook(ZO_UnitVisualizer_PowerShieldModule, 'ShowOverlay', function(_, _, info) 
  ApplyTemplate(info.overlayControls[1], 'ALT_PowerShieldBar')
  ApplyTemplate(info.overlayControls[2], 'ALT_PowerShieldBar')
end)











