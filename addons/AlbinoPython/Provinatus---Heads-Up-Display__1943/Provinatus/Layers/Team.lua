local function GetIconTexture(UnitTag)
  local Texture
  if IsUnitDead(UnitTag) then
    if IsUnitReincarnating(UnitTag) or IsUnitBeingResurrected(UnitTag) or DoesUnitHaveResurrectPending(UnitTag) then
      Texture = "/esoui/art/icons/poi/poi_groupboss_complete.dds"
    else
      Texture = "/esoui/art/icons/poi/poi_groupboss_incomplete.dds"
    end
  else
    if IsUnitGroupLeader(UnitTag) then
      Texture = "/esoui/art/icons/mapkey/mapkey_groupleader.dds"
    elseif Provinatus.SavedVars.Team.ShowRoleIcons then
      local IsDps, IsHealer, IsTank = GetGroupMemberRoles(UnitTag)
      local Role = "dps"
      if IsTank then
        Role = "tank"
      elseif IsHealer then
        Role = "healer"
      end
      Texture = "/esoui/art/lfg/lfg_" .. Role .. "_up.dds"
    else
      local Class = GetUnitClass(UnitTag)
      if Class == nil then
        Texture = "/esoui/art/icons/mapkey/mapkey_groupmember.dds"
      else
        Texture = "/esoui/art/icons/class/class_" .. Class .. ".dds"
      end
    end
  end
  return Texture
end

local function GetColor(UnitTag)
  local R, G, B = 1, 1, 1
  if not IsUnitDead(UnitTag) then
    local health, maxHealth, effectiveMaxHealth = GetUnitPower(UnitTag, POWERTYPE_HEALTH)
    local ratio = health / maxHealth
    G = ratio
    B = ratio
  elseif not DoesUnitHaveResurrectPending(UnitTag) then
    G = 0
    B = 0
  end
  return R, G, B
end

local function CreateElement(UnitTag)
  if AreUnitsEqual("player", UnitTag) then
    return
  end

  local X, Y, _ = GetMapPlayerPosition(UnitTag)
  local R, G, B = GetColor(UnitTag)
  local Alpha, Size, Leader
  if Provinatus.CustomTarget == GetUnitName(UnitTag) or IsUnitGroupLeader(UnitTag) then
    Alpha = Provinatus.SavedVars.Team.Leader.Alpha
    Size = Provinatus.SavedVars.Team.Leader.Size
    Leader = true
  else
    Alpha = Provinatus.SavedVars.Team.Teammate.Alpha
    Size = Provinatus.SavedVars.Team.Teammate.Size
    Leader = false
  end

  if
    Provinatus.SavedVars.Team.Growth.Enabled and
      not (IsUnitReincarnating(UnitTag) or IsUnitBeingResurrected(UnitTag) or DoesUnitHaveResurrectPending(UnitTag))
   then
    local health, maxHealth, effectiveMaxHealth = GetUnitPower(UnitTag, POWERTYPE_HEALTH)
    Size = Size + Size * (Provinatus.SavedVars.Team.Growth.MaxSize - 1) * (1 - health / maxHealth)
  end

  local Element = {
    X = X,
    Y = Y,
    Alpha = Alpha,
    Height = Size,
    Width = Size,
    Texture = GetIconTexture(UnitTag),
    R = R,
    G = G,
    B = B,
    UnitTag = UnitTag,
    Leader = Leader
  }

  return Element
end

local function GetLifebarDimensions(UnitTag, Icon)
  local Health, MaxHealth, EffectiveMaxHealth = GetUnitPower(UnitTag, POWERTYPE_HEALTH)
  local IconWidth, IconHeight = Icon:GetDimensions()
  return IconWidth * (Health / MaxHealth), IconHeight / 9
end

local function SetLifeBar(Element, Icon)
  if Icon.ProvLifebar == nil then
    Icon.ProvLifebar = WINDOW_MANAGER:CreateControl(nil, Icon, CT_TEXTURE)
    Icon.ProvLifebar:SetColor(1, 0, 0)
  end

  if
    Provinatus.SavedVars.Team.Lifebars.Enabled and
      (not Provinatus.SavedVars.Team.Lifebars.OnlyInCombat or IsUnitInCombat(Element.UnitTag))
   then
    Icon.ProvLifebar:SetDimensions(GetLifebarDimensions(Element.UnitTag, Icon))
    Icon.ProvLifebar:SetAlpha(1)
    Icon.ProvLifebar:SetAnchor(BOTTOM, Icon, BOTTOM, 0, 0)
  else
    Icon.ProvLifebar:SetAlpha(0)
  end
end

local function SetIconColor(Element, Icon)
  local Alpha
  -- TODO this doesn't look right. Fade happens in Provinatus.lua
  if Provinatus.SavedVars.Display.Fade then
    Alpha = Provinatus:Fade(Element.Projection.Distance)
  else
    Alpha = Element.Alpha
  end
  Icon:SetColor(Element.R, Element.G, Element.B, Alpha)
end

ProvinatusTeam = ZO_Object:Subclass()

function ProvinatusTeam:New(...)
  return ZO_Object.New(self)
end

function ProvinatusTeam:Initialize()
  self.Icons = {}
  self.Lifebars = {}
end

function ProvinatusTeam:Update()
  local Elements = {}
  if Provinatus.SavedVars.Team.Enabled and Provinatus.GroupSize > 1 then
    for UnitIndex = 1, Provinatus.GroupSize do
      local UnitTag = ZO_Group_GetUnitTagForGroupIndex(UnitIndex)
      local IsLeader = IsUnitGroupLeader(UnitTag)
      if
        (IsLeader and not Provinatus.SavedVars.Team.Leader.OnlyWhenDead) or
          (not IsLeader and not Provinatus.SavedVars.Team.Teammate.OnlyWhenDead) or
          IsUnitDead(UnitTag)
       then
        local Element = CreateElement(UnitTag)
        if
          Element ~= nil and IsUnitGrouped(UnitTag) and IsUnitOnline(UnitTag) and
            GetUnitZoneIndex("player") == GetUnitZoneIndex(UnitTag)
         then
          table.insert(Elements, Element)
        end
      end
    end
  end

  for Element, Icon in pairs(Provinatus:DrawElements(self, Elements)) do
    SetIconColor(Element, Icon)
    SetLifeBar(Element, Icon)
    if Element.Leader and Provinatus.SavedVars.Team.Leader.DrawOnTop then
      Icon:SetDrawLevel(1)
    else
      Icon:SetDrawLevel(0)
    end
  end
end

function ProvinatusTeam:GetMenu()
  local LeaderControls =
    ProvinatusMenu.GetIconSettingsMenu(
    "",
    function()
      return Provinatus.SavedVars.Team.Leader.Size
    end,
    function(value)
      Provinatus.SavedVars.Team.Leader.Size = value
    end,
    function()
      return Provinatus.SavedVars.Team.Leader.Alpha * 100
    end,
    function(value)
      Provinatus.SavedVars.Team.Leader.Alpha = value / 100
    end,
    ProvinatusConfig.Team.Leader.Size,
    ProvinatusConfig.Team.Leader.Alpha * 100
  )

  local TeamControls =
    ProvinatusMenu.GetIconSettingsMenu(
    "",
    function()
      return Provinatus.SavedVars.Team.Teammate.Size
    end,
    function(value)
      Provinatus.SavedVars.Team.Teammate.Size = value
    end,
    function()
      return Provinatus.SavedVars.Team.Teammate.Alpha * 100
    end,
    function(value)
      Provinatus.SavedVars.Team.Teammate.Alpha = value / 100
    end,
    ProvinatusConfig.Team.Teammate.Size,
    ProvinatusConfig.Team.Teammate.Alpha * 100
  )

  table.insert(
    LeaderControls,
    {
      type = "checkbox",
      name = PROVINATUS_ALWAYS_ON_TOP,
      getFunc = function()
        return Provinatus.SavedVars.Team.Leader.DrawOnTop
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Team.Leader.DrawOnTop = value
      end,
      tooltip = PROVINATUS_ALWAYS_ON_TOP_TT,
      width = "half",
      default = ProvinatusConfig.Team.Leader.DrawOnTop
    }
  )

  table.insert(
    LeaderControls,
    {
      type = "checkbox",
      name = PROVINATUS_ONLY_WHEN_DEAD,
      getFunc = function()
        return Provinatus.SavedVars.Team.Leader.OnlyWhenDead
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Team.Leader.OnlyWhenDead = value
      end,
      tooltip = PROVINATUS_ONLY_WHEN_DEAD_TT,
      width = "half",
      default = ProvinatusConfig.Team.Leader.OnlyWhenDead
    }
  )

  table.insert(
    TeamControls,
    {
      type = "checkbox",
      name = PROVINATUS_ONLY_WHEN_DEAD,
      getFunc = function()
        return Provinatus.SavedVars.Team.Teammate.OnlyWhenDead
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Team.Teammate.OnlyWhenDead = value
      end,
      tooltip = PROVINATUS_ONLY_WHEN_DEAD_TT,
      width = "half",
      default = ProvinatusConfig.Team.Teammate.OnlyWhenDead
    }
  )

  table.insert(
    TeamControls,
    {
      type = "checkbox",
      name = PROVINATUS_SHOW_ROLE_ICONS,
      getFunc = function()
        return Provinatus.SavedVars.Team.ShowRoleIcons
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Team.ShowRoleIcons = value
      end,
      tooltip = PROVINATUS_SHOW_ROLE_ICONS_TT,
      width = "half",
      default = Provinatus.SavedVars.Team.ShowRoleIcons
    }
  )

  return {
    type = "submenu",
    name = PROVINATUS_GROUP,
    tooltip = PROVINATUS_GROUP_TT,
    reference = "ProvinatusTeamMenu",
    icon = "/esoui/art/icons/mapkey/mapkey_groupleader.dds",
    controls = {
      [1] = {
        type = "submenu",
        name = PROVINATUS_LEADER_ICON,
        controls = LeaderControls
      },
      [2] = {
        type = "submenu",
        name = PROVINATUS_TEAM_ICON,
        controls = TeamControls
      },
      [3] = {
        type = "submenu",
        name = PROVINATUS_HEALTH_INDICATORS,
        controls = {
          [1] = {
            type = "submenu",
            name = PROVINATUS_HEALTH_SHOW,
            tooltip = PROVINATUS_HEALTH_SHOW_TT,
            controls = {
              [1] = {
                type = "checkbox",
                name = PROVINATUS_ENABLE,
                getFunc = function()
                  return Provinatus.SavedVars.Team.Lifebars.Enabled
                end,
                setFunc = function(value)
                  Provinatus.SavedVars.Team.Lifebars.Enabled = value
                end,
                width = "half",
                default = ProvinatusConfig.Team.Lifebars.Enabled
              },
              [2] = {
                type = "checkbox",
                name = PROVINATUS_HEALTH_COMBAT_ONLY,
                getFunc = function()
                  return Provinatus.SavedVars.Team.Lifebars.OnlyInCombat
                end,
                setFunc = function(value)
                  Provinatus.SavedVars.Team.Lifebars.OnlyInCombat = value
                end,
                tooltip = PROVINATUS_HEALTH_COMBAT_ONLY_TT,
                width = "half",
                default = ProvinatusConfig.Team.Lifebars.OnlyInCombat
              }
            }
          },
          [2] = {
            type = "submenu",
            name = PROVINATUS_EXPAND_ICON_SIZE,
            tooltip = PROVINATUS_EXPAND_ICON_SIZE_TT,
            controls = {
              [1] = {
                type = "checkbox",
                name = PROVINATUS_ENABLE,
                getFunc = function()
                  return Provinatus.SavedVars.Team.Growth.Enabled
                end,
                setFunc = function(value)
                  Provinatus.SavedVars.Team.Growth.Enabled = value
                end,
                width = "half",
                default = ProvinatusConfig.Team.Growth.Enabled
              },
              [2] = {
                type = "slider",
                name = PROVINATUS_MAX_SIZE,
                getFunc = function()
                  return Provinatus.SavedVars.Team.Growth.MaxSize
                end,
                setFunc = function(value)
                  Provinatus.SavedVars.Team.Growth.MaxSize = value
                end,
                min = 0,
                max = 10,
                step = 0.1,
                clampInput = true,
                decimals = 1,
                autoSelect = false,
                tooltip = PROVINATUS_MAX_SIZE_TT,
                width = "half"
              }
            }
          }
        }
      }
    }
  }
end
