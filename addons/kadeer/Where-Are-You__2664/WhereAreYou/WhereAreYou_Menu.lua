local WAY = WhereAreYou or {}
local LAM2 = LibAddonMenu2

function WAY:InitialiseAddonMenu()
  local panelData = {
    type = "panel",
    name = "WhereAreYou",
    displayName = "Where Are You",
    author = "kadeer",
    slashCommand = "/UTmenu",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  LAM2:RegisterAddonPanel("WAYAddonOptions", panelData)

  local optionsData = {}

  -- Waypoint Options
  table.insert(optionsData, {
    type = "header",
    name = "Waypoint",
  })

  table.insert(optionsData, {
    type = "checkbox",
    name = "Arrow",
    getFunc = function() return self.SV.waypointArrow end,
    setFunc = function(value) self.SV.waypointArrow = value self.waypoint.arrow:SetHidden(not value) end,
    default = WAY.defaults.waypointArrow,
  })

  table.insert(optionsData, {
    type = "checkbox",
    name = "Distance",
    getFunc = function() return self.SV.waypointDistance end,
    setFunc = function(value) self.SV.waypointDistance = value self.waypoint.distance:SetHidden(not value) end,
    default = WAY.defaults.waypointDistance,
  })

  table.insert(optionsData, {
    type = "checkbox",
    name = "Marker",
    getFunc = function() return self.SV.waypointMarker end,
    setFunc = function(value) self.SV.waypointMarker = value self.waypoint.marker:SetHidden(not value) end,
    default = WAY.defaults.waypointMarker,
  })


  -- Rally Options
  table.insert(optionsData, {
    type = "header",
    name = "Rally",
  })

  table.insert(optionsData, {
    type = "checkbox",
    name = "Arrow",
    getFunc = function() return self.SV.rallyArrow end,
    setFunc = function(value) self.SV.rallyArrow = value self.rally.arrow:SetHidden(not value) end,
    default = WAY.defaults.rallyArrow,
  })

  table.insert(optionsData, {
    type = "checkbox",
    name = "Distance",
    getFunc = function() return self.SV.rallyDistance end,
    setFunc = function(value) self.SV.rallyDistance = value self.rally.distance:SetHidden(not value) end,
    default = WAY.defaults.rallyDistance,
  })

  table.insert(optionsData, {
    type = "checkbox",
    name = "Marker",
    getFunc = function() return self.SV.rallyMarker end,
    setFunc = function(value) self.SV.rallyMarker = value self.rally.marker:SetHidden(not value) end,
    default = WAY.defaults.rallyMarker,
  })

  LAM2:RegisterOptionControls("WAYAddonOptions", optionsData)
end