VisualSwap = {}

VisualSwap.name = "VisualSwap"
CurrentWeaponBar = 1
VisualSwapReticleContainer = false;

function VisualSwapUpdate()
  VisualSwapText:SetText(string.format("%d", CurrentWeaponBar))
  ZO_ReticleContainerReticle:SetHidden(true)
  loadVisualSwapReticle()

  local playerStealth = GetUnitStealthState("player")
  local playerDisguised = GetUnitDisguiseState("player") ~= DISGUISE_STATE_NONE
  local targetUnitHighlighted = (GetUnitNameHighlightedByReticle() ~= "" and IsGameCameraUnitHighlightedAttackable())
  local targetUnitInteractable = GetGameCameraInteractableInfo()
  if (playerStealth > 0) then
    VisualSwapText:SetAnchor(CENTER, ZO_ReticleContainer, CENTER, - 35, 0)
    VisualSwapReticleContainer:SetHidden(true)

  elseif (targetUnitHighlighted) then
    VisualSwapReticleContainer:SetHidden(false)
    VisualSwapReticleContainer:SetScale(0.6)
    VisualSwapReticleContainer:SetColor(255, 255, 255, 100)
    VisualSwapText:SetAnchor(CENTER, VisualSwap, CENTER, - 16, - 10)

  elseif (targetUnitInteractable) then
    VisualSwapReticleContainer:SetHidden(false)
    VisualSwapReticleContainer:SetScale(0.6)
    VisualSwapReticleContainer:SetColor(0, 160, 200, 100)
    VisualSwapText:SetAnchor(CENTER, VisualSwap, CENTER, - 16, - 10)

  elseif (playerDisguised) then
    VisualSwapReticleContainer:SetHidden(false)
    VisualSwapReticleContainer:SetScale(0.6)
    VisualSwapReticleContainer:SetColor(0, 0, 0, 100)
    VisualSwapText:SetAnchor(CENTER, VisualSwap, CENTER, - 16, - 10)

  else
    VisualSwapReticleContainer:SetHidden(false)
    VisualSwapText:SetAnchor(CENTER, VisualSwap, CENTER, - 23, - 10)
    VisualSwapReticleContainer:SetScale(0.9)
  end
end

function VisualSwapInitialized()
  VisualSwap:ClearAnchors()
  VisualSwap:SetAnchor(CENTER, ZO_ReticleContainer, CENTER, 0, 0)

  VisualSwapText:ClearAnchors()
  VisualSwapText:SetAnchor(CENTER, VisualSwap, CENTER, 0, 0)

  VisualSwapText:SetFont(string.format("$(%s)|$(KB_%s)|%s", "CHAT_FONT", 16, "soft-shadow-thin"))
  VisualSwapText:SetColor(240, 240, 240, 0.5)

  createCustomReticle()

  d("initialized")
end

function animateText(control)
  isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()

  local timeline = ANIMATION_MANAGER:CreateTimeline()

  local popup = timeline:InsertAnimation(ANIMATION_SCALE, control)
  popup:SetScaleValues(0, 1)
  popup:SetDuration(300)
  popup:SetEasingFunction(myEasing)

  local fadeIn = timeline:InsertAnimation(ANIMATION_ALPHA, control)
  fadeIn:SetAlphaValues(0, 0.5)
  fadeIn:SetDuration(250)
  fadeIn:SetEasingFunction(ZO_EaseOutQuadratic)

  local colorChange = timeline:InsertAnimation(ANIMATION_COLOR, control)
  colorChange:SetApplyAlpha(false)
  colorChange:SetStartColor(0, 160, 200, 100)
  colorChange:SetEndColor(240, 240, 240, 100)
  colorChange:SetDuration(600)

  timeline:SetHandler('OnStop', function()
    control:ClearAnchors()
    control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
    control:SetColor(240, 240, 240, 0.5)
  end)

  timeline:PlayFromStart()
end

function animateRotateMainWeapon(control)
  isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()

  local timeline = ANIMATION_MANAGER:CreateTimeline()

  local rotate = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, control)
  rotate:SetStartRotation(0)
  rotate:SetEndRotation(-1.5708)
  rotate:SetDuration(300)

  timeline:SetHandler('OnStop', function()
    rotate:SetStartRotation(0)
    control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
  end)

  timeline:PlayFromStart()
end

function animateRotateBackWeapon(control)
  isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()

  local timeline = ANIMATION_MANAGER:CreateTimeline()

  local rotate = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, control)
  rotate:SetStartRotation(0)
  rotate:SetEndRotation(1.5708)
  rotate:SetDuration(300)

  timeline:SetHandler('OnStop', function()
    rotate:SetStartRotation(0)
    control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
  end)

  timeline:PlayFromStart()
end

function OnWeaponBarSwitch(eventcode, activeWeaponPair, locked)
  CurrentWeaponBar = activeWeaponPair
  animateText(VisualSwapText)

  if(activeWeaponPair == 1) then
    animateRotateMainWeapon(VisualSwapReticleContainer)
  else
    animateRotateBackWeapon(VisualSwapReticleContainer)
  end
end

function mouseFunction(eventcode)
  local inMouseMode = IsGameCameraUIModeActive()
  if ( not IsGameCameraUIModeActive() ) then
    VisualSwap:SetHidden(false)
  else
    VisualSwap:SetHidden(true)
  end
end

function createCustomReticle()
  VisualSwapReticleContainer = WINDOW_MANAGER:CreateControl("visualSwapCrosshair", ZO_ReticleContainer, CT_TEXTURE)
  VisualSwapReticleContainer:ClearAnchors()
  VisualSwapReticleContainer:SetAnchor(CENTER, ZO_ReticleContainer, CENTER, 0, 0)
end

function loadVisualSwapReticle()
  VisualSwapReticleContainer:SetTexture("VisualSwap\\Textures\\Crosshair.dds")
  VisualSwapReticleContainer:SetDimensions( 64, 64 )
  VisualSwapReticleContainer:SetColor(240, 240, 240, 0.5)
end

EVENT_MANAGER:RegisterForEvent("VisualSwapWeapons", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, OnWeaponBarSwitch)
EVENT_MANAGER:RegisterForEvent("VisualSwapMouse", EVENT_GAME_CAMERA_UI_MODE_CHANGED, mouseFunction)
