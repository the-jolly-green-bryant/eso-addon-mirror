PROV_LINEAR = 1
PROV_ORTHO = 2
PROV_PROJECTIONS = {
  [PROV_LINEAR] = {MethodName = "Rectilinear", HumanName = GetString(PROVINATUS_LINEAR)},
  [PROV_ORTHO] = {MethodName = "Orthographic", HumanName = GetString(PROVINATUS_FISHEYE)}
}

ProvinatusProjection = ZO_Object:Subclass()

function ProvinatusProjection:New(...)
  return ZO_Object.New(self)
end

function ProvinatusProjection:Project(X, Y)
  local Projection = {}
  Projection.DistanceM =
    math.min(
    LibGPS3:GetLocalDistanceInMeters(Provinatus.X, Provinatus.Y, X, Y),
    Provinatus.SavedVars.Display.MaxDistance
  )
  local Phi = (GetPlayerCameraHeading()  - math.atan2(Provinatus.X - X, Provinatus.Y - Y)) - math.pi / 2
  Projection.Distance =
    self[PROV_PROJECTIONS[Provinatus.SavedVars.Display.ProjectionCode].MethodName](self, Projection.DistanceM, Phi)
  Projection.XProjected = math.cos(Phi) * Projection.Distance
  Projection.YProjected = math.sin(Phi) * Projection.Distance
  if Provinatus.SavedVars.Display.Offset then
    Projection.YProjected = Projection.YProjected + Provinatus.SavedVars.Pointer.Size
  end

  return Projection
end

-- Derived from equations found here: https://en.wikipedia.org/wiki/Fisheye_lens
-- r=f*tan(theta)
function ProvinatusProjection:Rectilinear(DistanceM)
  return DistanceM / Provinatus.SavedVars.Display.MaxDistance * Provinatus.SavedVars.Display.Size
end

-- r=f*sin(theta)
-- 1 / sqrt(2), normalizes value to be between 0 and 1
local INV_SQRT_2 = 0.7071
function ProvinatusProjection:Orthographic(DistanceM)
  local ModifiedDistance = DistanceM + DistanceM * (Provinatus.SavedVars.Display.Orthomultiplier)
  local MaxDistance = Provinatus.SavedVars.Display.MaxDistance
  return math.sin(math.atan(math.min(ModifiedDistance, MaxDistance) / MaxDistance)) / INV_SQRT_2 *
    Provinatus.SavedVars.Display.Size
end

-- Hotkeys
function ProvinatusProjection:CycleProjection()
  local NextProjection = Provinatus.SavedVars.Display.ProjectionCode + 1
  if not PROV_PROJECTIONS[NextProjection] then
    NextProjection = 1
  end

  Provinatus.SavedVars.Display.ProjectionCode = NextProjection
  d("[Provinatus]:" .. PROV_PROJECTIONS[Provinatus.SavedVars.Display.ProjectionCode].HumanName)
end

local LogFisheye = function()
  if Provinatus.SavedVars.Display.LogToChat then
    d(
      zo_strformat(
        "[Provinatus]:Fisheye - <<1>>",
        ZO_LocalizeDecimalNumber(zo_roundToNearest(Provinatus.SavedVars.Display.Orthomultiplier, 0.01))
      )
    )
  end
end

local FISHEYE_RATE = 0.25
function ProvinatusProjection:IncreaseFisheye()
  if Provinatus.SavedVars.Display.ProjectionCode == PROV_ORTHO then
    Provinatus.SavedVars.Display.Orthomultiplier =
      math.min(
      Provinatus.SavedVars.Display.Orthomultiplier + Provinatus.SavedVars.Display.Orthomultiplier * FISHEYE_RATE,
      100
    )
    LogFisheye()
  else
    d(GetString(PROVINATUS_ORTHO_WARN))
  end
end

function ProvinatusProjection:DecreaseFisheye()
  if Provinatus.SavedVars.Display.ProjectionCode == PROV_ORTHO then
    Provinatus.SavedVars.Display.Orthomultiplier =
      math.max(
      Provinatus.SavedVars.Display.Orthomultiplier - Provinatus.SavedVars.Display.Orthomultiplier * FISHEYE_RATE,
      0.1
    )
    LogFisheye()
  else
    d(GetString(PROVINATUS_ORTHO_WARN))
  end
end
