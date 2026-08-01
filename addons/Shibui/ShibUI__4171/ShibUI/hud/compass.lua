-----------------------------------------------------------
-- ShibUI Compass/Boss Bar Module
-----------------------------------------------------------
local SUI = SUI
local sv

SUI.Compass = SUI.Compass or {}
local Compass = SUI.Compass

local Log = function(...) SUI.Debug:Log("Compass & BossBar", ...) end

ApplyTemplateToControl(ZO_CompassFrame, "SUI_CompassFrame")
ApplyTemplateToControl(ZO_Compass, "SUI_Compass")
ApplyTemplateToControl(ZO_BossBar, "SUI_BossBar")

-- Don't Resize Compass
ZO_CompassFrame:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
ZO_CompassFrame:UnregisterForEvent(EVENT_SCREEN_RESIZED)

-- Don't Resize Compass Height
function COMPASS_FRAME:SetBossBarActive (active)
  self.bossBarActive = active
  self:RefreshVisible()
end

function Compass:Initialize()
    sv = SUI.SavedVars.saved
    Log("Initialized")
end