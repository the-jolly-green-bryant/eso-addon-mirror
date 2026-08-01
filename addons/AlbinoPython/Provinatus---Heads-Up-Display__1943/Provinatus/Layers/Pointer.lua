local Texture = "esoui/art/floatingmarkers/quest_icon_assisted.dds"

-- From Exterminatus http://www.esoui.com/downloads/info329-0.1.html
local function NormalizeAngle(Angle)
  if Angle > math.pi then
    return Angle - 2 * math.pi
  end
  if Angle < -math.pi then
    return Angle + 2 * math.pi
  end
  return Angle
end

local function IsValidTarget(GroupNumber)
  return GroupNumber > 0 and GetUnitName(GetGroupUnitTagByIndex(GroupNumber)) ~= GetUnitName("player") and
    IsUnitOnline(GetGroupUnitTagByIndex(GroupNumber))
end

-- Group number can be found in the "Group & Activity Finder" menu.
local function SetTarget(GroupNumber)
  local UnitTag = GetGroupUnitTagByIndex(GroupNumber)
  if GetGroupSize() > 0 and GroupNumber then
    if IsValidTarget(GroupNumber) then
      TargetUnitName = GetUnitName(UnitTag)
      d(TargetUnitName .. GetUnitDisplayName(UnitTag))
      Provinatus.CustomTarget = TargetUnitName
    else
      d(GetString(PROVINATUS_CANNOT_SET_TARGET))
    end
  else
    d(GetString(PROVINATUS_NO_TARGET_PROVIDED))
    Provinatus.ClearTarget()
  end
end

-- Gets the index of the current target or 0 otherwise.
local function GetTargetIndex()
  for i = 1, GetGroupSize() do
    if Provinatus.CustomTarget ~= nil and GetUnitName(GetGroupUnitTagByIndex(i)) == Provinatus.CustomTarget then
      return i
    elseif Provinatus.CustomTarget == nil and GetGroupUnitTagByIndex(i) == GetGroupLeaderUnitTag() then
      return i
    end
  end

  return 0
end

local function GetCustomTargetUnitTag()
  if GetGroupSize() > 0 then
    if Provinatus.CustomTarget ~= nil then
      -- TODO Cache this value
      for i = 1, GetGroupSize() do
        UnitTag = GetGroupUnitTagByIndex(i)
        if GetUnitName(UnitTag) == Provinatus.CustomTarget and IsUnitOnline(UnitTag) then
          return UnitTag
        end
      end
      return GetGroupLeaderUnitTag()
    else
      return nil
    end
  else
    return nil
  end
end

ProvinatusPointer = ZO_Object:Subclass()

function ProvinatusPointer:New(...)
  self.Settings = Provinatus.SavedVars.Pointer
  return ZO_Object.New(self)
end

function ProvinatusPointer:ClearTarget()
  d(GetString(PROVINATUS_CLEARED_CUSTOM_TARGET))
  Provinatus.CustomTarget = nil
end

function ProvinatusPointer:NextTarget()
  local GroupSize = GetGroupSize()
  if GroupSize < 2 then
    d(GetString(PROVINATUS_NEED_TWO_MEMBERS))
    return
  end
  -- Get current target sort index since we don't retain it
  local CurrentTargetIndex = GetTargetIndex()
  for i = 1, GroupSize do
    local TargetIndex = i + CurrentTargetIndex
    if TargetIndex > GroupSize then
      TargetIndex = TargetIndex % GroupSize
    end
    if IsValidTarget(TargetIndex) then
      SetTarget(TargetIndex)
      return
    end
  end
  d(GetString(PROVINATUS_NO_SUITABLE_TARGET))
end

function ProvinatusPointer:SnapToNearestDeadTarget()
  -- Get list of dead units
  local Deadies = {}
  for i = 1, GetGroupSize() do
    local UnitTag = ZO_Group_GetUnitTagForGroupIndex(i)
    if IsUnitDead(UnitTag) then
      table.insert(Deadies, UnitTag)
    end
  end

  -- iterate list and find closest
  local ClosestUnitTag, ClosestDistance
  local MyX, MyY, MyHeading = GetMapPlayerPosition("player")
  for i = 1, #Deadies do
    local UnitTag = Deadies[i]
    local X, Y, Heading = GetMapPlayerPosition(UnitTag)
    local Distance = math.sqrt(math.pow(MyX - X, 2) + math.pow(MyY - Y, 2))
    if ClosestDistance == nil or ClosestDistance > Distance then
      ClosestUnitTag = UnitTag
      ClosestDistance = Distance
    end
  end

  -- snap to that unit
  if ClosestUnitTag then
    TargetUnitName = GetUnitName(ClosestUnitTag)
    -- TODO localized strings
    d(TargetUnitName .. GetUnitDisplayName(ClosestUnitTag) .. " is dead!")
    Provinatus.CustomTarget = TargetUnitName
  else
    d("No one is dead!")
  end
end

function ProvinatusPointer:Initialize()
  self.Icon = WINDOW_MANAGER:CreateControl(nil, Provinatus.TopLevelWindow, CT_TEXTURE)
  self.Icon:SetTexture(Texture)
end

function ProvinatusPointer:Update()
  local Elements = {}
  local Leader = GetCustomTargetUnitTag() or GetGroupLeaderUnitTag()
  if
    Leader and self.Settings.Enabled and GetGroupSize() > 0 and not AreUnitsEqual("player", Leader) and
      GetUnitZone(Leader) == GetUnitZone("player")
   then
    table.insert(
      Elements,
      {
        X = Provinatus.X,
        Y = Provinatus.Y,
        Alpha = self.Settings.Alpha,
        Texture = Texture,
        Size = self.Settings.Size
      }
    )
  end

  for Element, Icon in pairs(Provinatus:DrawElements(self, Elements)) do
    local Tx, Ty, Th = GetMapPlayerPosition(Leader)
    local Dx = Provinatus.X - Tx
    local Dy = Provinatus.Y - Ty
    local Angle = math.pi - NormalizeAngle(math.atan2(Dx, Dy) - GetPlayerCameraHeading())
    local Magnitude = math.abs(math.pi - Angle)
    Icon:SetTextureRotation(-Angle)
    Icon:SetColor(Magnitude / math.pi, math.pi - Magnitude, 0, Element.Alpha)
  end
end

function ProvinatusPointer:GetMenu()
  return {
    type = "submenu",
    name = PROVINATUS_POINTER,
    reference = "ProvinatusPointerMenu",
    icon = Texture,
    controls = {
      {
        type = "checkbox",
        name = PROVINATUS_ENABLE,
        getFunc = function()
          return self.Settings.Enabled
        end,
        setFunc = function(value)
          self.Settings.Enabled = value
        end,
        tooltip = PROVINATUS_POINTER_TT,
        width = "full",
        default = ProvinatusConfig.Pointer.Enabled
      },
      {
        type = "submenu",
        name = PROVINATUS_POINTER,
        controls = ProvinatusMenu.GetIconSettingsMenu(
          PROVINATUS_POINTER_SETTINGS,
          function()
            return self.Settings.Size
          end,
          function(value)
            self.Settings.Size = value
          end,
          function()
            return self.Settings.Alpha * 100
          end,
          function(value)
            self.Settings.Alpha = value / 100
          end,
          ProvinatusConfig.Pointer.Size,
          ProvinatusConfig.Pointer.Alpha * 100,
          function()
            return not self.Settings.Enabled
          end
        )
      }
    }
  }
end

function ProvinatusPointer:SetMenuIcon()
  ProvinatusPointerMenu.icon:SetColor(0, 1, 0, 1)
  ProvinatusPointerMenu.icon:SetTextureRotation(math.pi)
end
