PJD = {}
PJD.name = "PleaseJustDebuff"
PJD.variableVersion = 1

PJD.defaults = {
  ["left"] = 860,
  ["top"] = 420,
  showOnlyInCombat = false,
  trackers = {},
}

function PJD.Initialize()
  PJD.SV = ZO_SavedVars:NewAccountWide(PJD.name .. "Vars", PJD.variableVersion, nil, PJD.defaults)

  PJD.LoadPosition()
  PJD.fragment = ZO_HUDFadeSceneFragment:New(PJD_Grid)
  if IsUnitInCombat("player") or not PJD.SV.showOnlyInCombat then
    PJD.AddToHUD()
  end
  PJD.BuildMenu()
  PJD.BuildDebuffTrackers()

  EVENT_MANAGER:RegisterForEvent(PJD.name, EVENT_PLAYER_COMBAT_STATE, PJD.OnCombatState)
end

function PJD.LoadPosition()
  local left  = PJD.SV.left
  local top   = PJD.SV.top
  PJD_Grid:ClearAnchors()
  PJD_Grid:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function PJD.SavePosition()
  PJD.SV.left = PJD_Grid:GetLeft()
  PJD.SV.top = PJD_Grid:GetTop()
end

function PJD.ShouldHideUI(_, newState)
  if not PJD.SV.showOnlyInCombat then return end
  if newState == SCENE_FRAGMENT_HIDDEN then
    PJD_Grid:SetHidden(true)
  end
  PJD_Grid:SetHidden(not IsUnitInCombat("player"))
end

function PJD.AddToHUD()
  HUD_SCENE:AddFragment(PJD.fragment)
  HUD_UI_SCENE:AddFragment(PJD.fragment)
end

function PJD.RemoveFromHUD()
  HUD_SCENE:RemoveFragment(PJD.fragment)
  HUD_UI_SCENE:RemoveFragment(PJD.fragment)
  PJD_Grid:SetHidden(true)
end

function PJD.OnAddOnLoaded(_, addonName)
  if addonName ~= PJD.name then return end
  EVENT_MANAGER:UnregisterForEvent(PJD.name, EVENT_ADD_ON_LOADED)
  PJD.Initialize()
end

EVENT_MANAGER:RegisterForEvent(PJD.name, EVENT_ADD_ON_LOADED, PJD.OnAddOnLoaded)
