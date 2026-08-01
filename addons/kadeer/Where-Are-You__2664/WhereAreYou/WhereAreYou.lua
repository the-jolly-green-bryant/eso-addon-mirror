local WAY = WhereAreYou or {}

WAY.name = "WhereAreYou"
WAY.displayName = "Where Are You"
WAY.version = "0"

WAY.waypoint = {}
WAY.rally = {}
WAY.groupie = {}

function WAY:OnMapPing(eventCode, pingEventType, pingType, pingTag, offsetX, offsetY, isLocalPlayerOwner)
  if pingTag == "waypoint" then
    if pingEventType == PING_EVENT_ADDED then
      --self.waypoint:SetTarget(offsetX, offsetY)
      self.waypoint:SetTarget(GetMapPlayerWaypoint())
    end
    if pingEventType == PING_EVENT_REMOVED then
      self.waypoint:SetTarget(0, 0)
    end
  end

  if pingTag == "rally" then
    if pingEventType == PING_EVENT_ADDED then
      --self.rally:SetTarget(offsetX, offsetY)
      self.rally:SetTarget(GetMapRallyPoint())
    end
    if pingEventType == PING_EVENT_REMOVED then
      self.rally:SetTarget(0, 0)
    end
  end
end

-- function WAY:OnPlayerActivated(eventCode, initial)
--   d("player activated")
--   self.waypoint:SetTarget(0, 0)
--   self.rally:SetTarget(0, 0)
-- end

function WAY:SetupEvents(toggle)
  if toggle then
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAP_PING, function(...) self:OnMapPing(...) end)
    --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED , function(...) self:OnPlayerActivated(...) end)
  else

  end
end

function WAY:Initialise()
  -- versioning
  local manager = GetAddOnManager()

  for i = 1, manager:GetNumAddOns() do
    local name, _, _, _, _, state = manager:GetAddOnInfo(i)
    if name == self.name then
      self.version = manager:GetAddOnVersion(i)
    end
  end

  -- saved vars
  self.SV = ZO_SavedVars:NewAccountWide("WhereAreYouSettings", self.version, GetWorldName(), self.defaults)

  -- waypoint arrow
  self.waypoint = Lib3DArrow:CreateArrow({
  	depthBuffer = false,
  })

  -- rally arrow
  local rallyPointData = {
    depthBuffer = false,
    arrowMagnitude = 5,
    arrowScale = 1,
    arrowHeight = 1,
    arrowColour = "FF0000",

    distanceDigits = 4,
    distanceScale = 25,
    distanceColour = "FFFFFF",

    markerColour = "FF0000",
    markerScale = 1,
  }
  self.rally = Lib3DArrow:CreateArrow(rallyPointData)

  -- group member arrow
  -- local groupieData = {
  --   arrow = true,
  --   depthBuffer = false,
  --   arrowMagnitude = 5,
  --   arrowScale = 1,
  --   arrowHeight = 1,
  --   arrowColour = "00FFFF",

  --   distance = true,
  --   distanceDigits = 4,
  --   distanceScale = 25,
  --   distanceColour = "FFFFFF",

  --   marker = true,
  --   markerColour = "00FFFF",
  --   markerScale = 2,
  -- }

  -- self.groupie = Lib3DArrow:CreateArrow(oneguyData)

  --GetMapPlayerPosition("player")

  self:InitialiseAddonMenu()
  self:SetupEvents(true)
end

function WAY.OnLoad(event, addonName)
  if addonName ~= WAY.name then return end
  EVENT_MANAGER:UnregisterForEvent(WAY.name, EVENT_ADD_ON_LOADED, WAY.OnLoad)
  WAY:Initialise()
end

function WAY:Get()
  d(autoArrow:GetTarget())
end

EVENT_MANAGER:RegisterForEvent(WAY.name, EVENT_ADD_ON_LOADED, WAY.OnLoad)

SLASH_COMMANDS["/refresh"] = function() WhereAreYou:RefreshCustomArrow() end
SLASH_COMMANDS["/gettarget"] = function() WhereAreYou:Get() end