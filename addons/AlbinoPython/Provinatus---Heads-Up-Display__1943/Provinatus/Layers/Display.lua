local ZOOMRATE = 0.1
local MINDISTANCE = 5
local MAXDISTANCE = 9000

ProvinatusDisplay = ZO_Object:Subclass()

function ProvinatusDisplay:New(...)
  return ZO_Object.New(self)
end

function ProvinatusDisplay:GetMenu()
  local AvailableProjections = {}
  local Menu = {
    type = "submenu",
    name = PROVINATUS_SETTINGS,
    icon = "esoui/art/tutorial/gamepad/gp_playermenu_icon_settings.dds",
    controls = {
      self:GetDisplayMenu(),
      self:GetScaleMenu(),
      self:GetProjectionMenu(),
      self:GetHotkeysMenu(),
      self:GetLoggingMenu()
    }
 }

  return Menu
end

function ProvinatusDisplay:GetDisplayMenu()
  local controls = {
    {
      type = "slider",
      name = PROVINATUS_HUD_SIZE,
      getFunc = function()
        return Provinatus.SavedVars.Display.Size
      end,
      setFunc = function(value)
        ProvinatusDisplaySetSize(value)
      end,
      min = 25,
      max = 750,
      step = 1,
      clampInput = true,
      decimals = 0,
      autoSelect = true,
      inputLocation = "below",
      width = "full",
      default = ProvinatusConfig.Display.Size
    },
    {
      type = "slider",
      name = PROVINATUS_HORIZONTAL_POSITION,
      getFunc = function()
        return Provinatus.SavedVars.Display.X
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.X = value
        ProvinatusMoveDisplay(Provinatus.SavedVars.Display.X, Provinatus.SavedVars.Display.Y)
      end,
      min = math.floor(-GuiRoot:GetWidth() / 2),
      max = math.floor(GuiRoot:GetWidth() / 2),
      step = 1,
      clampInput = true,
      decimals = 0,
      autoSelect = true,
      inputLocation = "below",
      width = "half",
      default = ProvinatusConfig.Display.X
    },
    {
      type = "slider",
      name = PROVINATUS_VERTICAL_POSITION,
      getFunc = function()
        return Provinatus.SavedVars.Display.Y
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.Y = value
        ProvinatusMoveDisplay(Provinatus.SavedVars.Display.X, Provinatus.SavedVars.Display.Y)
      end,
      min = math.floor(-GuiRoot:GetHeight() / 2),
      max = math.floor(GuiRoot:GetHeight() / 2),
      step = 1,
      clampInput = true,
      decimals = 0,
      autoSelect = true,
      inputLocation = "below",
      width = "half",
      default = ProvinatusConfig.Display.Y
    },
    {
      type = "checkbox",
      name = PROVINATUS_OFFSET_CENTER,
      reference = "ProvinatusOffsetCenterCheckbox",
      getFunc = function()
        return Provinatus.SavedVars.Display.Offset
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.Offset = value
        self:SetMenuIcon()
      end,
      tooltip = PROVINATUS_OFFSET_CENTER_TT,
      width = "full",
      default = ProvinatusConfig.Display.Offset
    },
    {
      type = "slider",
      name = PROVINATUS_REFRESH_RATE,
      getFunc = function()
        return Provinatus.SavedVars.Display.RefreshRate
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.RefreshRate = value
        Provinatus:SetRefreshRate()
      end,
      min = 24,
      max = 144,
      step = 1,
      clampInput = true,
      decimals = 0,
      autoSelect = true,
      inputLocation = "below",
      width = "full",
      default = ProvinatusConfig.Display.RefreshRate
    }
  }

  return {
    type = "submenu",
    name = PROVINATUS_DISPLAY,
    controls = controls,
    icon = "/esoui/art/icons/poi/poi_areaofinterest_complete.dds"
  }
end

function ProvinatusDisplay:GetProjectionMenu()
  local controls = {
    {
      type = "dropdown",
      name = "Projection",
      choices = {GetString(PROVINATUS_LINEAR), GetString(PROVINATUS_FISHEYE)},
      choicesValues = {PROV_LINEAR, PROV_ORTHO},
      getFunc = function()
        return Provinatus.SavedVars.Display.ProjectionCode
      end,
      setFunc = function(var)
        Provinatus.SavedVars.Display.ProjectionCode = var
      end,
      tooltip = PROVINATUS_PROJECTION_TT,
      sort = "name-down",
      width = "full",
      scrollable = true,
      requiresReload = false,
      choicesTooltips = {
        GetString(PROVINATUS_LINEAR_TT),
        GetString(PROVINATUS_FISHEYE_TT)
      },
      default = ProvinatusConfig.Display.ProjectionCode
    },
    {
      type = "slider",
      name = PROVINATUS_FISHEYE_AMOUNT,
      getFunc = function()
        return Provinatus.SavedVars.Display.Orthomultiplier
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.Orthomultiplier = value
      end,
      min = 0.1,
      max = 100,
      step = 1,
      clampInput = true,
      decimals = 0,
      autoSelect = true,
      inputLocation = "below",
      width = "full",
      default = ProvinatusConfig.Display.Orthomultiplier,
      tooltip = PROVINATUS_ZOOM_TT,
      disabled = function()
        return Provinatus.SavedVars.Display.ProjectionCode == PROV_LINEAR
      end
    }
  }
  return {
    type = "submenu",
    name = PROVINATUS_PROJECTION,
    controls = controls,
    icon = "/art/fx/texture/dot_clusters01.dds"
  }
end

function ProvinatusDisplay:GetScaleMenu()
  local controls = {
    {
      type = "slider",
      name = PROVINATUS_MAX_DISTANCE,
      tooltip = PROVINATUS_MAX_DISTANCE_TT,
      getFunc = function()
        return Provinatus.SavedVars.Display.MaxDistance
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.MaxDistance = value
      end,
      min = MINDISTANCE,
      max = MAXDISTANCE,
      step = 1,
      clampInput = true,
      decimals = 0,
      autoSelect = true,
      inputLocation = "below",
      width = "half",
      default = ProvinatusConfig.Display.MaxDistance,
      tooltip = PROVINATUS_ZOOM_TT
    },
    {
      type = "checkbox",
      name = "Show distant",
      getFunc = function()
        return Provinatus.SavedVars.Display.ShowDistant
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.ShowDistant = value
      end,
      tooltip = "Hides icons further than the max distance",
      width = "half",
      default = ProvinatusConfig.Display.ShowDistant
    },
    {
      type = "checkbox",
      name = PROVINATUS_FADE,
      getFunc = function()
        return Provinatus.SavedVars.Display.Fade
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.Fade = value
      end,
      tooltip = PROVINATUS_FADE_TT,
      width = "full",
      default = ProvinatusConfig.Display.Fade
    },
    {
      type = "slider",
      name = PROVINATUS_FADE_MIN,
      getFunc = function()
        return Provinatus.SavedVars.Display.MinFade
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.MinFade = value
      end,
      min = 0,
      max = 1,
      step = 0.01,
      decimals = 2,
      autoSelect = true,
      inputLocation = "below",
      width = "full",
      default = ProvinatusConfig.Display.MinFade,
      tooltip = PROVINATUS_FADE_MIN_TT,
      disabled = function()
        return not Provinatus.SavedVars.Display.Fade
      end
    }
  }

  return {
    type = "submenu",
    name = PROVINATUS_MAP_SCALE,
    controls = controls,
    icon = "/art/fx/texture/clockworksigil.dds"
  }
end

function ProvinatusDisplay:GetHotkeysMenu()
  local controls = {
    {
      type = "slider",
      name = PROVINATUS_DISPLAY_TRANSLATE_DISTANCE,
      getFunc = function()
        return Provinatus.SavedVars.Display.TranslateDistance
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.TranslateDistance = value
      end,
      min = 1,
      max = 100,
      step = 1,
      autoSelect = true,
      inputLocation = "below",
      width = "full",
      default = ProvinatusConfig.Display.TranslateDistance,
      tooltip = PROVINATUS_DISPLAY_TRANSLATE_DISTANCE_TT,
      disabled = function()
        return false
      end
    },
    {
      type = "slider",
      name = PROVINATUS_DISPLAY_SIZE_CHANGE_AMOUNT,
      getFunc = function()
        return Provinatus.SavedVars.Display.SizeChangeAmount
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.SizeChangeAmount = value
      end,
      min = 1,
      max = 50,
      step = 1,
      autoSelect = true,
      inputLocation = "below",
      width = "full",
      default = ProvinatusConfig.Display.SizeChangeAmount,
      tooltip = PROVINATUS_DISPLAY_SIZE_CHANGE_AMOUNT_TT,
      disabled = function()
        return false
      end
    }
  }

  return {
    type = "submenu",
    name = PROVINATUS_HOTKEYS,
    controls = controls,
    icon = "/art/fx/texture/eye_sigil_pupil_alpha.dds"
  }
end

function ProvinatusDisplay:GetLoggingMenu()
  local controls = {
    {
      type = "checkbox",
      name = PROVINATUS_LOGTOCHAT,
      getFunc = function()
        return Provinatus.SavedVars.Display.LogToChat
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Display.LogToChat = value
      end,
      tooltip = PROVINATUS_LOGTOCHAT_TT,
      width = "half",
      default = ProvinatusConfig.Display.LogToChat
    },
    {
      type = "checkbox",
      name = PROVINATUS_LOG_AT_STARTUP,
      tooltip = PROVINATUS_LOG_AT_STARTUP_TT,
      getFunc = function()
        return Provinatus.SavedVars.PrintInfoAtStart
      end,
      setFunc = function(value)
        Provinatus.SavedVars.PrintInfoAtStart = value
      end,
      width = "half",
      default = ProvinatusConfig.PrintInfoAtStart
    }
  }

  return {
    type = "submenu",
    name = PROVINATUS_LOGGING,
    controls = controls,
    icon = "/art/fx/texture/arcanist_trianglerune_01.dds"
  }
end

function ProvinatusDisplay:SetMenuIcon()
  if not ProvinatusOffsetCenterCheckbox.Reticle then
    ProvinatusOffsetCenterCheckbox.Reticle =
      WINDOW_MANAGER:CreateControl(nil, ProvinatusOffsetCenterCheckbox, CT_TEXTURE)
    ProvinatusOffsetCenterCheckbox.Reticle:SetTexture("esoui/art/worldmap/map_centerreticle.dds")
    ProvinatusOffsetCenterCheckbox.Reticle:SetAlpha(1)
    ProvinatusOffsetCenterCheckbox.Reticle:SetAnchor(CENTER, ProvinatusOffsetCenterCheckbox, CENTER, 0, 0)
    ProvinatusOffsetCenterCheckbox.Reticle:SetDimensions(24, 24)
    ProvinatusOffsetCenterCheckbox.Reticle:SetTextureRotation(math.pi / 4)

    ProvinatusOffsetCenterCheckbox.Pointer =
      WINDOW_MANAGER:CreateControl(nil, ProvinatusOffsetCenterCheckbox.Reticle, CT_TEXTURE)
    ProvinatusOffsetCenterCheckbox.Pointer:SetTexture("esoui/art/floatingmarkers/quest_icon_assisted.dds")
    ProvinatusOffsetCenterCheckbox.Pointer:SetDimensions(24, 24)
    ProvinatusOffsetCenterCheckbox.Pointer:SetTextureRotation(math.pi)
    ProvinatusOffsetCenterCheckbox.Pointer:SetColor(0, 1, 0, 1)
  end

  local AnchorPosition
  if Provinatus.SavedVars.Display.Offset then
    AnchorPosition = BOTTOM
  else
    AnchorPosition = CENTER
  end
  ProvinatusOffsetCenterCheckbox.Pointer:SetAnchor(CENTER, ProvinatusOffsetCenterCheckbox, AnchorPosition, 0, 0)
end

function ProvinatusZoomIn()
  Provinatus.SavedVars.Display.MaxDistance =
    math.max(Provinatus.SavedVars.Display.MaxDistance - Provinatus.SavedVars.Display.MaxDistance * 0.175, MINDISTANCE)
  if Provinatus.SavedVars.Display.LogToChat then
    d(
      zo_strformat(
        "[Provinatus]:Max Distance - <<1>> meters",
        ZO_LocalizeDecimalNumber(math.floor(Provinatus.SavedVars.Display.MaxDistance))
      )
    )
  end
end

function ProvinatusZoomOut()
  Provinatus.SavedVars.Display.MaxDistance =
    math.min(Provinatus.SavedVars.Display.MaxDistance + Provinatus.SavedVars.Display.MaxDistance * 0.175, MAXDISTANCE)
  if Provinatus.SavedVars.Display.LogToChat then
    d(
      zo_strformat(
        "[Provinatus]:Max Distance - <<1>> meters",
        ZO_LocalizeDecimalNumber(math.floor(Provinatus.SavedVars.Display.MaxDistance))
      )
    )
  end
end

function ProvinatusDisplayLeft()
  ProvinatusMoveDisplay(Provinatus.SavedVars.Display.X - Provinatus.SavedVars.Display.TranslateDistance, Provinatus.SavedVars.Display.Y)
end

function ProvinatusDisplayRight()
  ProvinatusMoveDisplay(Provinatus.SavedVars.Display.X + Provinatus.SavedVars.Display.TranslateDistance, Provinatus.SavedVars.Display.Y)
end

function ProvinatusDisplayUp()
  ProvinatusMoveDisplay(Provinatus.SavedVars.Display.X, Provinatus.SavedVars.Display.Y - Provinatus.SavedVars.Display.TranslateDistance)
end

function ProvinatusDisplayDown()
  ProvinatusMoveDisplay(Provinatus.SavedVars.Display.X, Provinatus.SavedVars.Display.Y + Provinatus.SavedVars.Display.TranslateDistance)
end

function ProvinatusDisplayResetPosition()
  ProvinatusMoveDisplay(0, 0)
end

function ProvinatusMoveDisplay(x, y)
  Provinatus.SavedVars.Display.X = x
  Provinatus.SavedVars.Display.Y = y
  Provinatus.TopLevelWindow:SetAnchor(CENTER, nil, CENTER, Provinatus.DisplaySettings.X, Provinatus.DisplaySettings.Y)
  if Provinatus.SavedVars.Display.LogToChat then
    d(
      zo_strformat(
        "[Provinatus]:Moved Display to X: <<1>>, Y: <<2>>",
        ZO_LocalizeDecimalNumber(math.floor(Provinatus.SavedVars.Display.X)),
        ZO_LocalizeDecimalNumber(math.floor(Provinatus.SavedVars.Display.Y))
      )
    )
  end
end

function ProvinatusDisplayIncreaseSize()
  ProvinatusDisplaySetSize(Provinatus.SavedVars.Display.Size + Provinatus.SavedVars.Display.SizeChangeAmount)
end

function ProvinatusDisplayDecreaseSize()
  ProvinatusDisplaySetSize(Provinatus.SavedVars.Display.Size - Provinatus.SavedVars.Display.SizeChangeAmount)
end

function ProvinatusDisplayResetSize()
  ProvinatusDisplaySetSize(ProvinatusConfig.Display.Size)
end

function ProvinatusDisplaySetSize(size)
  Provinatus.SavedVars.Display.Size = size
  if Provinatus.SavedVars.Display.LogToChat then
    d(
      zo_strformat(
        "[Provinatus]:Set display size to <<1>>",
        ZO_LocalizeDecimalNumber(math.floor(Provinatus.SavedVars.Display.Size))
      )
    )
  end
end