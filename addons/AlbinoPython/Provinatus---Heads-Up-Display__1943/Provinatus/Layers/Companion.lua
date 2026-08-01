ProvinatusCompanion = ZO_Object:Subclass()

-- Actual drawing of icon happens in Teams.lua. This is just to present a separate menu.
function ProvinatusCompanion:New(...)
  return ZO_Object.New(self)
end

function ProvinatusCompanion:Update()
  local Elements = {}
  if Provinatus:GetSettings("Companion").Enabled and HasActiveCompanion() then
    local X, Y, _, IsInCurrentMap = GetMapPlayerPosition("companion")
    if IsInCurrentMap then
      local Element = {
        X = X,
        Y = Y,
        Alpha = Provinatus.SavedVars.Companion.Color.a,
        Size =Provinatus.SavedVars.Companion.Size,
        Texture = ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ACTIVE_COMPANION].texture
      }

      table.insert(Elements, Element)
    end
  end

  local icons = Provinatus:DrawElements(self, Elements)
  for Element, Icon in pairs(icons) do
    Icon:SetColor(
        Provinatus.SavedVars.Companion.Color.r,
        Provinatus.SavedVars.Companion.Color.g,
        Provinatus.SavedVars.Companion.Color.b,
        Provinatus.SavedVars.Companion.Color.a
      )

    if Provinatus.SavedVars.Companion.BackgroundEnabled then
      Icon:SetDrawLayer(1)
      if (Icon.BGTexture == nil) then
        local bg = WINDOW_MANAGER:CreateControl(nil, Icon, CT_TEXTURE)
        bg:SetAnchor(CENTER, Icon, CENTER)
        bg:SetDrawLevel(0)
        bg:SetTexture(Provinatus.SavedVars.Companion.BackgroundTexture)
        Icon.BGTexture = bg
      end

      Icon.BGTexture:SetColor(
        Provinatus.SavedVars.Companion.BackgroundColor.r,
        Provinatus.SavedVars.Companion.BackgroundColor.g,
        Provinatus.SavedVars.Companion.BackgroundColor.b,
        Provinatus.SavedVars.Companion.BackgroundColor.a
      )

      Icon.BGTexture:SetDimensions(Icon:GetDimensions())
      Icon.BGTexture:SetTexture(Provinatus.SavedVars.Companion.BackgroundTexture)
      Icon.BGTexture:SetHidden(false)
    else
      if Icon.BGTexture ~= nil and not Icon.BGTexture:IsHidden() then
        Icon.BGTexture:SetHidden(true)
      end
    end
  end
end

function ProvinatusCompanion:GetMenu()
  local function getSize()
    return Provinatus.SavedVars.Companion.Size
  end

  local function setSize(value)
    Provinatus.SavedVars.Companion.Size = value
    ProvinatusCompanionBackgroundIconDropdown:SetIconSize(Provinatus.SavedVars.Companion.Size)
  end

  local function getAlpha()
    return Provinatus.SavedVars.Companion.Color.a * 100
  end

  local function setAlpha(value)
    Provinatus.SavedVars.Companion.Color.a = value / 100
  end

  local Controls = {
   {
      type = "checkbox",
      name = PROVINATUS_ENABLE,
      getFunc = function()
        return Provinatus.SavedVars.Companion.Enabled
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Companion.Enabled = value
      end,
      width = "full",
      tooltip = PROVINATUS_COMPANION_ENABLE_TT,
      default = ProvinatusConfig.Companion.Enabled
    },
    {
      type = "slider",
      name = PROVINATUS_ICON_SIZE,
      getFunc = getSize,
      setFunc = setSize,
      min = 20,
      max = 150,
      step = 1,
      clampInput = true,
      decimals = 0,
      autoSelect = true,
      inputLocation = "below",
      tooltip = PROVINATUS_ICON_SIZE_TT,
      width = "full",
      default = ProvinatusConfig.Companion.Size,
      disabled = function()
        return not Provinatus.SavedVars.Companion.Enabled
      end
    },
    {
      type = "colorpicker",
      name = PROVINATUS_ICON_COLOR,
      getFunc = function()
        return Provinatus.SavedVars.Companion.Color.r, Provinatus.SavedVars.Companion.Color.g, Provinatus.SavedVars.Companion.Color.b, Provinatus.SavedVars.Companion.Color.a
      end,
      setFunc = function(Red, Green, Blue, Alpha)
        Provinatus.SavedVars.Companion.Color.r = Red
        Provinatus.SavedVars.Companion.Color.g = Green
        Provinatus.SavedVars.Companion.Color.b = Blue
        Provinatus.SavedVars.Companion.Color.a = Alpha
        self:UpdateMenuIconColors()
      end,
      tooltip = PROVINATUS_ICON_COLOR_TT,
      width = "full",
      default = {
        r = ProvinatusConfig.Companion.Color.r,
        g = ProvinatusConfig.Companion.Color.g,
        b = ProvinatusConfig.Companion.Color.b,
        a = ProvinatusConfig.Companion.Color.a
      },
      disabled = function()
        return not Provinatus.SavedVars.Companion.Enabled
      end
    },
    {
      type = "checkbox",
      name = PROVINATUS_ICON_BACKGROUND_ENABLED,
      getFunc = function()
        return Provinatus.SavedVars.Companion.BackgroundEnabled
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Companion.BackgroundEnabled = value
        self:UpdateMenuIconColors()
      end,
      width = "full",
      tooltip = PROVINATUS_ICON_BACKGROUND_ENABLED_TT,
      default = ProvinatusConfig.Companion.BackgroundEnabled,
      disabled = function()
        return not Provinatus.SavedVars.Companion.Enabled
      end
    },
    {
      type = "colorpicker",
      name = PROVINATUS_ICON_BACKGROUND_COLOR,
      getFunc = function()
        return Provinatus.SavedVars.Companion.BackgroundColor.r, Provinatus.SavedVars.Companion.BackgroundColor.g, Provinatus.SavedVars.Companion.BackgroundColor.b, Provinatus.SavedVars.Companion.BackgroundColor.a
      end,
      setFunc = function(Red, Green, Blue, Alpha)
        Provinatus.SavedVars.Companion.BackgroundColor.r = Red
        Provinatus.SavedVars.Companion.BackgroundColor.g = Green
        Provinatus.SavedVars.Companion.BackgroundColor.b = Blue
        Provinatus.SavedVars.Companion.BackgroundColor.a = Alpha
        self:UpdateMenuIconColors()
      end,
      tooltip = PROVINATUS_ICON_BACKGROUND_COLOR_TT,
      width = "half",
      default = {
        r = ProvinatusConfig.Companion.BackgroundColor.r,
        g = ProvinatusConfig.Companion.BackgroundColor.g,
        b = ProvinatusConfig.Companion.BackgroundColor.b,
        a = ProvinatusConfig.Companion.BackgroundColor.a
      },
      disabled = function()
        return not Provinatus.SavedVars.Companion.Enabled or not Provinatus.SavedVars.Companion.BackgroundEnabled
      end
    },
    {
      type = "iconpicker",
      name = PROVINATUS_COMPANION_BACKGROUND_ICON, -- or string id or function returning a string
      choices = {
        "/art/fx/texture/aoe_circle.dds",
        "/art/fx/texture/circlesoftoutter.dds",
        "/art/fx/texture/whirlwind_circle.dds",
        "/art/fx/texture/quartercircle.dds",
        "/art/fx/texture/arcanist_textring_01.dds",
        "/art/fx/texture/arcanist_trianglerune_01.dds",
        "/art/fx/texture/ashpile.dds",
        "/art/fx/texture/box_softinside.dds",
        "/art/fx/texture/box_soft.dds",
        "/art/fx/texture/bubblesolid.dds",
        "/art/fx/texture/bw_obelisk_groundrunes_01.dds",
        "/art/fx/texture/clockworksigil.dds",
        "/art/fx/texture/dot_clusters01.dds",
        "/art/fx/texture/frostcrystals_outter_1024x01.dds",
        "/art/fx/texture/eye_sigil_pupil_alpha.dds"
      },
      getFunc = function() 
        return Provinatus.SavedVars.Companion.BackgroundTexture
      end,
      setFunc = function(var) 
        Provinatus.SavedVars.Companion.BackgroundTexture = var
        self:UpdateMenuIconColors()
      end,
      tooltip = PROVINATUS_COMPANION_BACKGROUND_ICON_TT,
      maxColumns = 5,
      visibleRows = 3,
      iconSize = Provinatus.SavedVars.Companion.Size,
      defaultColor = ZO_ColorDef:New(ProvinatusConfig.Companion.BackgroundColor.r, ProvinatusConfig.Companion.BackgroundColor.g, ProvinatusConfig.Companion.BackgroundColor.b, ProvinatusConfig.Companion.BackgroundColor.a),
      width = "half",
      disabled = function()
        return not Provinatus.SavedVars.Companion.Enabled or not Provinatus.SavedVars.Companion.BackgroundEnabled
      end,
      default = "/art/fx/texture/aoe_circle.dds", -- default value or function that returns the default value (optional)
      reference = "ProvinatusCompanionBackgroundIconDropdown", -- unique global reference to control (optional)
    },
    {
      type = "button",
      name = PROVINATUS_COMPANION_RESET_SETTINGS,
      func = function()
        ZO_DeepTableCopy(ProvinatusConfig.Companion, Provinatus.SavedVars.Companion)
        self:UpdateMenuIconColors()
        ProvinatusCompanionBackgroundIconDropdown:SetIconSize(Provinatus.SavedVars.Companion.Size)
      end,
      tooltip = PROVINATUS_COMPANION_RESET_SETTINGS_TT,
      width = "full"
    }
  }

  return {
    type = "submenu",
    name = SI_COMPANION_MENU_ROOT_TITLE,
    controls = Controls,
    icon = ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ACTIVE_COMPANION].texture,
    reference = "ProvinatusCompanionMenu",
  }
end

function ProvinatusCompanion:SetMenuIcon()
  local bg = WINDOW_MANAGER:CreateControl(nil, ProvinatusCompanionMenu.icon, CT_TEXTURE)
  bg:SetAnchor(CENTER, ProvinatusCompanionMenu.icon, CENTER)
  bg:SetDimensions(ProvinatusCompanionMenu.icon:GetDimensions())
  bg:SetTexture(Provinatus.SavedVars.Companion.BackgroundTexture)
  ProvinatusCompanionMenu.icon.BGTexture = bg
  self:UpdateMenuIconColors()
end

function ProvinatusCompanion:UpdateMenuIconColors()
  ProvinatusCompanionMenu.icon:SetColor(
    Provinatus.SavedVars.Companion.Color.r,
    Provinatus.SavedVars.Companion.Color.g,
    Provinatus.SavedVars.Companion.Color.b,
    Provinatus.SavedVars.Companion.Color.a
  )

  if Provinatus.SavedVars.Companion.BackgroundEnabled then
    ProvinatusCompanionMenu.icon.BGTexture:SetColor(
      Provinatus.SavedVars.Companion.BackgroundColor.r,
      Provinatus.SavedVars.Companion.BackgroundColor.g,
      Provinatus.SavedVars.Companion.BackgroundColor.b,
      Provinatus.SavedVars.Companion.BackgroundColor.a
    )

    ProvinatusCompanionMenu.icon.BGTexture:SetTexture(Provinatus.SavedVars.Companion.BackgroundTexture)
    ProvinatusCompanionBackgroundIconDropdown:SetColor(ZO_ColorDef:New(Provinatus.SavedVars.Companion.BackgroundColor.r, Provinatus.SavedVars.Companion.BackgroundColor.g, Provinatus.SavedVars.Companion.BackgroundColor.b, Provinatus.SavedVars.Companion.BackgroundColor.a))
    ProvinatusCompanionMenu.icon.BGTexture:SetHidden(false)
  else
    ProvinatusCompanionMenu.icon.BGTexture:SetHidden(true)
  end
end
