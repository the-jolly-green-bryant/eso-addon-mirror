HarvestRoute = {}
HarvestRoute.name = "HarvestRoute"
HarvestRoute.displayName = 'HarvestRoute for Harvestmap'
HarvestRoute.version = "1.1.0"
HarvestRoute.author = "generic"
HarvestRoute.settingsVersion = 3
HarvestRoute.savedVars = {}

HarvestRoute.defaultSettings = {
  trackerRange = 5,
  enableTrackerWindow = true,
  showTrackerWindow = false,
  usePathHeuristic = true,
  wm = {
    x = 1500,
    y = 0,
  },
}

local LibAddonMenu2 = LibAddonMenu2

local Farm = Harvest.farm
local Editor = Farm.editor
local Path = Harvest.path
local MapCache = nil
local Helper = Farm.helper

local atan2 = math.atan2
local zo_round = _G["zo_round"]
local GetPlayerCameraHeading = _G["GetPlayerCameraHeading"]
local GetMapPlayerPosition = _G["GetMapPlayerPosition"]

local HarvestRouteButton = nil
local isActive = false
local isTrackerVisible = false
local currentZoneId = nil
local lastNodeId = nil
local lastNodeAddedToPath = nil
local lastPathIndex = nil
local closesPathNodeId = nil
local closestOutOfPathId = nil
local pathNodeId = nil
local pathNodes = {}
local playerX = 0
local playerY = 0
local playerZ = 0
local ourPathChange = false
local trackerUpdateNeeded = false




local function initialize( eventCode, addOnName )  
    
    if ( addOnName ~= HarvestRoute.name ) then
        return
    end
    HarvestRoute.savedVars = ZO_SavedVars:NewAccountWide("HarvestRouteVars", HarvestRoute.settingsVersion, nil, HarvestRoute.defaultSettings)
    
    local padding = 30
    local control = WINDOW_MANAGER:CreateControlFromVirtual('HarvestRouteButton', HarvestFarmGenerator, "ZO_DefaultButton")
    control:SetText(HarvestRoute.GetLocalization( "buttonstarttracker" ))
    control:SetAnchor(TOPLEFT, Harvest.farm.generator.generatorBar , BOTTOMLEFT, 0, 14)
    control:SetWidth(HarvestFarmGenerator:GetWidth() - padding)
    control:SetClickSound("Click")
    control:SetHandler("OnClicked", HarvestRoute.OnButton )
    HarvestRouteButton = control
    local lastControl = control
    
    local control = WINDOW_MANAGER:CreateControl(nil, HarvestFarmGenerator, CT_LABEL)
    control:SetFont("ZoFontGame")
    control:SetText(HarvestRoute.GetLocalization( "tourtrackerdescription" ))
    control:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 10)
    control:SetWidth(HarvestFarmGenerator:GetWidth() - padding)
    
    HarvestRouteTrackerPathInfoTitle:SetText( HarvestRoute.GetLocalization( "pathinfotitle" ) )
    
    HarvestRouteTrackerNearestNodeTitle:SetText( HarvestRoute.GetLocalization( "nearestnodetitle" ))
    HarvestRouteTrackerNearestNodeTitle:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, TOP, HarvestRoute.GetLocalization( "nearestnodetooltip" ))
    end)
    HarvestRouteTrackerNearestNodeTitle:SetHandler("OnMouseExit", function(self)
        ZO_Tooltips_HideTextTooltip()
    end)
    
    HarvestRouteTrackerLastPathNodeTitle:SetText( HarvestRoute.GetLocalization( "lastpathnodetitle" ))
    HarvestRouteTrackerLastPathNodeTitle:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, TOP, HarvestRoute.GetLocalization( "lastpathnodetooltip" ))
    end)
    HarvestRouteTrackerLastPathNodeTitle:SetHandler("OnMouseExit", function(self)
        ZO_Tooltips_HideTextTooltip()
    end)
    
    HarvestRouteTrackerButton:SetText( HarvestRoute.GetLocalization( "buttonstarttracker" ) )
    HarvestRouteTrackerNearestArrow:SetColor( 0.5, 0.75, 0.5, 0.75)
    HarvestRouteTrackerPathArrow:SetColor( 0.25, 0.25, 0.25, 0.75)
    
    HarvestRoute.InitializeSettingsMenu()
    
    
    EVENT_MANAGER:RegisterForEvent("HarvestRoutePlayerActivated", EVENT_PLAYER_ACTIVATED, HarvestRoute.OnPlayerLoaded )
    
    Harvest.callbackManager:RegisterForEvent(Harvest.events.TOUR_CHANGED, HarvestRoute.checkPath )
    HarvestRoute.ApplyStyle()
    if HarvestRoute.savedVars.enableTrackerWindow and HarvestRoute.savedVars.showTrackerWindow then
      HarvestRoute.SetTrackerHidden( false ) 
      HarvestRoute.InitTracker()
      HarvestRoute.UpdateTracker()
    end
    
end

local function TrackerWindowDisabled() return not HarvestRoute.savedVars.enableTrackerWindow end

function HarvestRoute.InitializeSettingsMenu()
  local panel = {
    type = "panel",
    name = HarvestRoute.name,
    displayName = HarvestRoute.displayName,
    author = HarvestRoute.author,
    version = HarvestRoute.version,
    registerForRefresh = true,
    registerForDefaults = true,
  }
  local options = {
      {
          type = "description",
          text = HarvestRoute.GetLocalization("addonsettingstext"),
      },
      {
        type = "checkbox",
        name = HarvestRoute.GetLocalization("enabletrackerwindow"),
        tooltip = HarvestRoute.GetLocalization("enabletrackerwindowtooltip"),
        getFunc = function () return HarvestRoute.savedVars.enableTrackerWindow end,
        setFunc = function (value) 
            HarvestRoute.savedVars.enableTrackerWindow = value
            if not value then HarvestRouteTracker:SetHidden( true ) 
            elseif HarvestRoute.savedVars.alwaysShowTracker then HarvestRouteTracker:SetHidden( false )
            end
          end,
        default = HarvestRoute.defaultSettings.enableTrackerWindow,
      },
      {
        type = "checkbox",
        name = HarvestRoute.GetLocalization("showtrackerwindow"),
        tooltip = HarvestRoute.GetLocalization("showtrackerwindowtooltip"),
        getFunc = function () return HarvestRoute.showTrackerWindow end,
        setFunc = function (value) 
            HarvestRoute.savedVars.showTrackerWindow = value
            if value then 
              HarvestRoute.SetTrackerHidden( false ) 
              HarvestRoute.InitTracker()
              HarvestRoute.UpdateTracker()
            end
          end,
        default = HarvestRoute.defaultSettings.showTrackerWindow,
        disabled = TrackerWindowDisabled,
      },
      {
        type = "slider",
        name = HarvestRoute.GetLocalization("routerangemultiplier"),
        tooltip = HarvestRoute.GetLocalization("routerangemultipliertooltip"),
        min = 3,
        max = 20,
        getFunc = function () return HarvestRoute.savedVars.trackerRange end,
        setFunc = function (value) HarvestRoute.savedVars.trackerRange = value end,
        default = HarvestRoute.defaultSettings.trackerRange,
      },
      {
        type = "checkbox",
        name = HarvestRoute.GetLocalization("usepathheuristics"),
        tooltip = HarvestRoute.GetLocalization("usepathheuristicstooltip"),
        getFunc = function () return HarvestRoute.savedVars.usePathHeuristic end,
        setFunc = function (value) 
            HarvestRoute.savedVars.usePathHeuristic = value
          end,
        default = HarvestRoute.defaultSettings.usePathHeuristic,
      },
    }
    LibAddonMenu2:RegisterAddonPanel(HarvestRoute.name.."OptionsMenu", panel)
    LibAddonMenu2:RegisterOptionControls(HarvestRoute.name.."OptionsMenu", options)
end

function HarvestRoute.OnButton()
    if isActive then
      isActive = false
      HarvestRoute.StopTracker()
    else
      isActive = true
      HarvestRoute.StartTracker()
    end
    HarvestRoute.UpdateTracker()
end

function HarvestRoute.StartTracker()
      EVENT_MANAGER:RegisterForUpdate("HarvestRouteUpdatePosition", 50, HarvestRoute.OnUpdate)
      

      local mapMetaData = Harvest.mapTools:GetViewedMapMetaData()
      MapCache = Harvest.Data:GetMapCache( mapMetaData )
      currentZoneId = GetUnitZoneIndex("player")

      Farm = Harvest.farm
      Editor = Harvest.editor
      Helper = Farm.helper

      HarvestRoute.SetTrackerHidden(false)
      HarvestRoute.InitTracker()
end

function HarvestRoute.StopTracker()
      EVENT_MANAGER:UnregisterForUpdate("HarvestRouteUpdatePosition")
      HarvestRoute.InitTracker()
end

function HarvestRoute.OnPlayerLoaded()
      local newZoneId = GetUnitZoneIndex("player")
      if currentZoneId and currentZoneId == newZoneId then
        return
      end
      HarvestRoute.debug('zone switched')
      lastNodeId = nil
      pathNodeId = nil
      lastPathIndex = nil
      pathNodes = {}
      currentZoneId = newZoneId
      if isActive then
        HarvestRoute.OnButton()
      end
      if HarvestRoute.savedVars.enableTrackerWindow then
        if HarvestRoute.savedVars.showTrackerWindow or isTrackerVisible then
          HarvestRoute.SetTrackerHidden( false )
          HarvestRoute.UpdateTracker()
        end
      end 
end

-- reset pathnodes when path has changed from outside, and either last node or last path node are invalid 
function HarvestRoute.checkPath(event, path)
  if ourPathChange then return end -- if we are responsible we do not care.
  local validpath = false
  local validnode = false 
  if lastNodeId and MapCache then
    -- does the nodeId still exist?
    if MapCache.pinTypeId[lastNodeId] then
      validnode = true
      -- check if our path information still works
      if pathNodeId and Farm.path then
        local index = Farm.path:GetIndex(pathNodeId)
        if index and (index == lastPathIndex) then
          validpath = true
        end
      end
    end
  end
  if not validnode then
    HarvestRoute.debug('last node invalid')
    lastNodeId = nil
  end
  if not validpath then
    HarvestRoute.debug('last path index invalid')
    lastNodeId = nil
    pathNodeId = nil
    lastPathIndex = nil
    pathNodes = {}
  end
  HarvestRoute.UpdateTracker()
end

function HarvestRoute.OnUpdate (time)
    if isActive then
      playerX, playerY, playerZ = Harvest.GetPlayer3DPosition()
      local nodeId, nodeDistance, nodePinType = HarvestRoute.GetClosestNode()
      if nodeId then
        if nodePinType ~= Harvest.UNKNOWN and nodeId ~= lastNodeId and (nodeDistance < HarvestRoute.savedVars.trackerRange) then
          HarvestRoute.debug('node in range: '..nodeId)
          local x, y = MapCache:GetLocal(nodeId)
          if Farm.path then
            local index = Farm.path:GetIndex(nodeId)
            if index then
              
              -- check if we are far enough away from the last inserted node before switching
              local switchToPathNode = true
              if lastNodeAddedToPath then
                dx = MapCache.worldX[nodeId] - MapCache.worldX[lastNodeAddedToPath]
                dy = MapCache.worldY[nodeId] - MapCache.worldY[lastNodeAddedToPath]
                distance = dx * dx + dy * dy
                checkDistance = HarvestRoute.savedVars.trackerRange * HarvestRoute.savedVars.trackerRange
                if (checkDistance > distance) then
                  switchToPathNode = false
                end 
              end
              
              if switchToPathNode then
                HarvestRoute.debug('path node '..nodeId..' ')
                pathNodeId = nodeId
                lastPathIndex = index
              end
            else
              if pathNodeId then
                HarvestRoute.debug('insert '..nodeId..' after path node '..pathNodeId..' ')
                if HarvestRoute.savedVars.usePathHeuristic then
                  pathNodeId = HarvestRoute.getSmartInsertNode(pathNodeId, lastNodeAddedToPath, nodeId)
                end
                ourPathChange = true
                Farm.path:InsertAfter(pathNodeId, nodeId)
                pathNodeId = nodeId
                lastNodeAddedToPath = nodeId
                lastPathIndex = Farm.path:GetIndex(nodeId)
                ourPathChange = false
                Harvest.farm.display:Refresh(Farm.path, Harvest.farm.display.selectedPins, Harvest.farm.display.selectedMapCache)
                Harvest.farm.editor.statusLabel:SetText(Harvest.farm.editor.textConstructor())
                
                -- if we are farming, update the next pin so we can actually finish the loop if we want to
                if Farm.helper:IsRunning() then
                  Farm.helper.nextPathIndex = lastPathIndex
                  Farm.helper:UpdateToNextTarget()
                end
              end
            end
          else --create a new path
            pathNodes[#pathNodes + 1] = nodeId
            HarvestRoute.debug('added '..nodeId..' as path node '..#pathNodes)
            if #pathNodes > 2 then
              ourPathChange = true
              path = Harvest.path:New(MapCache)
              path:GenerateFromNodeIds(pathNodes, 1, #pathNodes)
              Farm:SetPath(path)
              ourPathChange = false
              lastPathIndex = Farm.path:GetIndex(nodeId)
              lastNodeAddedToPath = nodeId
              pathNodeId = nodeId
              pathNodes = {}
            end
          end
          lastNodeId = nodeId
        end --nodeDistance
        HarvestRoute.UpdateTracker()
        trackerUpdateNeeded = false
      else
        if trackerUpdateNeeded then
          HarvestRoute.UpdateTracker()
        end
      end --nodeId
    end --isActive
end

function HarvestRoute.getNodeDistance(n1, n2)
  local distance = 10000
  if MapCache.worldX and MapCache.worldX[n1] and MapCache.worldX[n2] then
    local dx = MapCache.worldX[n1] - MapCache.worldX[n2]
    local dy = MapCache.worldY[n1] - MapCache.worldY[n2]
    distance = ( dx * dx + dy * dy ) ^ 0.5
  end
  return distance
end 

function HarvestRoute.GetPathNodeWithOffset(nodeId, offset)
  local index = Farm.path:GetIndex(nodeId)
  local oldindex = index
  if not index then return nil end
  if not offset then return nodeId end
  local numNodes = Farm.path.numNodes
  --offset = offset % numNodes
  index = index + offset + numNodes
  index = ((index - 1) % numNodes) +1
  if index < 1 then 
    --index = index + numNodes 
  elseif index > numNodes then
    --index = index - numNodes
  end
  HarvestRoute.debug("Index ".. oldindex .. " + " .. offset .. " = " .. index .. " (" .. numNodes .. ")" )
  return Farm.path.nodeIndices[index]
end
function HarvestRoute.GetNextPathNode(nodeId)
  return HarvestRoute.GetPathNodeWithOffset(nodeId, 1)
end
function HarvestRoute.GetPreviousPathNode(nodeId)
  return HarvestRoute.GetPathNodeWithOffset(nodeId, -1)
end


-- be "smart" and detect if adding before or after either n1 or n2 wourld result in a better path
-- should remove most zigzags when backtracking or enhancing existing paths
function HarvestRoute.getSmartInsertNode(n1, n2, addNode)
  --if not n2 then return n1 end
  --if n1 == n2 then return n1 end
  HarvestRoute.debug("getSmartInsertNode")
  -- HarvestRoute.debug("checkPathHeuristic " .. n1 .." / ".. n2 .. " (" .. addNode ..")")
  local result = n1
  if Farm.path then
    local n1_result, n1_distance = HarvestRoute.getBetterInsertNode(n1, addNode)
    result = n1_result
    if n2 and n1 ~= n2 then
      local n2_result, n2_distance = HarvestRoute.getBetterInsertNode(n2, addNode)
      if n2_distance < n1_distance then
        result = n2_result
      end
    end
  end
  return result
end

-- return previous node, if the resulting path would be better (basically insert before node, instead of insert after)
function HarvestRoute.getBetterInsertNode(node, addNode)
  local nextnode = HarvestRoute.GetNextPathNode(node)
  local prevnode = HarvestRoute.GetPreviousPathNode(node)
  if prevnode and nextnode then
    -- using stackoverflow https://stackoverflow.com/questions/33155240/how-to-check-if-a-point-is-between-two-other-points-but-not-limited-to-be-align
    -- add = A, node = B, next / prev = C
    local a_prev_to_node = HarvestRoute.getNodeDistance(prevnode, node)
    local a_node_to_next = HarvestRoute.getNodeDistance(node, nextnode)
    local b_prev_to_add  = HarvestRoute.getNodeDistance(prevnode, addNode)
    local b_add_to_next  = HarvestRoute.getNodeDistance(addNode, nextnode)
    local c_node_to_add  = HarvestRoute.getNodeDistance(node, addNode)

    -- path length changes for both node and prevnode
    local d_next = a_prev_to_node + c_node_to_add + b_add_to_next - a_node_to_next
    local d_prev = b_prev_to_add + c_node_to_add + a_node_to_next - a_prev_to_node
    
    -- some mathemagics which are not needed
    --[[
    local node_between_next = HarvestRoute.NodeAisBetweenBandCusingDistances(a_node_to_next, b_add_to_next, c_node_to_add)
    local node_between_prev = HarvestRoute.NodeAisBetweenBandCusingDistances(a_prev_to_node, b_prev_to_add, c_node_to_add)

    local prev_crossed = HarvestRoute.linesAreCrossed(prevnode, addNode, node, nextnode)
    local next_crossed = HarvestRoute.linesAreCrossed(prevnode, node, addNode, nextnode)
    --]]
    if d_prev < d_next then
      HarvestRoute.debug("PrevNode " .. prevnode .. " (prevnode shorter " .. d_prev .. " vs. " .. d_next .. ")")
      return prevnode, d_prev
    else
      HarvestRoute.debug("Node " .. node .. " (node shorter " .. d_prev .. " vs. " .. d_next.. ")")
      return node, d_next
    end
  end
  return node, 0
end

-- checks if the two line-segments defined by points [a/b] to [c/d] and [p/q] to [r/s] do intersect or not
function HarvestRoute.intersects(a,b,c,d, p,q,r,s)
  local det, gamma, lambda;
  det = (c - a) * (s - q) - (r - p) * (d - b);
  if det == 0 then return false end
  lambda = ((s - q) * (r - a) + (p - r) * (s - b)) / det;
  gamma = ((b - d) * (r - a) + (c - a) * (s - b)) / det;
  return (0 < lambda and lambda < 1) and (0 < gamma and gamma < 1);
end
    
function HarvestRoute.linesAreCrossed(node_a, node_b, node_c, node_d)
  local wx = MapCache.worldX
  local wy = MapCache.worldY
  return HarvestRoute.intersects(
      wx[node_a],wy[node_a],
      wx[node_b],wy[node_b],
      wx[node_c],wy[node_c],
      wx[node_d],wy[node_d])
end

function HarvestRoute.NodeAisBetweenBandC(nodeA, nodeB, nodeC)
  local a = HarvestRoute.getNodeDistance(nodeB, nodeC)
  local b = HarvestRoute.getNodeDistance(nodeC, nodeA)
  local c = HarvestRoute.getNodeDistance(nodeA, nodeB)
  return HarvestRoute.NodeAisBetweenBandCusingDistances(a, b, c)
end

function HarvestRoute.NodeAisBetweenBandCusingDistances(a, b, c)
  return (a*a + b*b >= c*c and a*a + c*c >= b*b)
end
-- get the closest node to the player, using HarvestMap MapCache Divisions (and only check 4 divisions, from -50 to +50 from current position)
function HarvestRoute.GetClosestNode()
    local bestNodeId = nil
    if not MapCache then --yeah, no cache no cookies.
      return nil, nil
    end
    
    local halfDivisionInMeters = zo_floor(MapCache.DivisionWidthInMeters / 2) --should be 50 most of the time, but lets keep it dynamic
    local numDivisions = MapCache.numDivisions 
    local totalNumDivisions = MapCache.TotalNumDivisions
    
    local half_before_x = playerX - halfDivisionInMeters
    local half_before_y = playerY - halfDivisionInMeters
    
    local index = (zo_floor(half_before_x / MapCache.DivisionWidthInMeters) + zo_floor(half_before_y / MapCache.DivisionWidthInMeters) * numDivisions) % MapCache.TotalNumDivisions
    
    local bestDistance = halfDivisionInMeters * halfDivisionInMeters
    local bestPathDistance = bestDistance
    local bestOutOfPathDistance = bestDistance
    local bestOutOfPathId = nil
    local divisions = MapCache.divisions
    
    -- check all pintypes, and the 4 divisions that contain the 100 x 100 square around the player
    if divisions then
      for _, pinTypeId in pairs(Harvest.PINTYPES) do
        local pinDivision = MapCache.divisions[pinTypeId]
        if pinDivision then
          for i = index, index + 1 do
            for j = 0, 1 do
              division = pinDivision[(i + j * numDivisions) % totalNumDivisions] or {}
              if division then
                -- check all node in current division, if there are closer nodes to the player
                for _, nodeId in pairs(division) do
                  if MapCache.worldX then
                    dx = MapCache.worldX[nodeId] - playerX
                    dy = MapCache.worldY[nodeId] - playerY
                    distance = dx * dx + dy * dy
                    if distance < bestDistance then
                      bestNodeId = nodeId
                      bestNodePinType = pinTypeId
                      bestDistance = distance
                    end
                    inPath = nil
                    if Farm.path then
                      inPath = Farm.path:GetIndex(nodeId)
                    end
                    if inPath then
                      if distance < bestPathDistance then
                        bestPathDistance = distance
                        closesPathNodeId = nodeId
                      end
                    else
                      if distance < bestOutOfPathDistance then 
                        bestOutOfPathDistance = distance
                        bestOutOfPathId = nodeId
                      end
                    end
                  end
                end
              end
            end -- for j
          end -- for i
        end -- if pinDivision
      end --for pinType
      if bestPathDistance == (halfDivisionInMeters * halfDivisionInMeters) then
        closesPathNodeId = nil
      end
      if closestOutOfPathId ~= bestOutOfPathId  then
        trackerUpdateNeeded = true
        closestOutOfPathId = bestOutOfPathId
      end
      if bestNodeId then
        realDistance = bestDistance ^ 0.5
        return bestNodeId, realDistance, bestNodePinType
      end 
    end
    return nil, nil
end

-- UI element management
function HarvestRoute:OnMoveStop( )
  HarvestRoute.savedVars.wm.x = self:GetLeft()
  HarvestRoute.savedVars.wm.y = self:GetTop()
  HarvestRoute.savedVars.wm.width = self:GetWidth()
  HarvestRoute.savedVars.wm.height = self:GetHeight()
end

function HarvestRoute.ApplyStyle()
  HarvestRouteTracker:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, HarvestRoute.savedVars.wm.x, HarvestRoute.savedVars.wm.y )
end


function HarvestRoute.SetTrackerHidden(value)
  isTrackerVisible = false
  if not HarvestRoute.savedVars.enableTrackerWindow then value = true end
  HarvestRouteTracker:SetHidden(value)
  isTrackerVisible = not value
end

function HarvestRoute.GetNodeDescription(nodeId)
    local description = HarvestRoute.GetLocalization( "nodeinfounknown" )
    local angle = nil
    if MapCache and MapCache.worldX and MapCache.worldX[nodeId] then
      local x, y, z = Harvest.GetPlayer3DPosition()
      
      local targetX = MapCache.worldX[nodeId]
      local targetY = MapCache.worldY[nodeId]
      local dx = playerX - targetX
      local dy = playerY - targetY
      local distanceInMeters = (dx * dx + dy * dy)^0.5
      nodeX = zo_round( MapCache.worldX[nodeId] * 100 ) / 100
      nodeY = zo_round( MapCache.worldY[nodeId] * 100 ) / 100
      pinType = MapCache.pinTypeId[nodeId]
      node = Harvest.GetLocalization( "pintype" ..pinType )
      description = zo_strformat( HarvestRoute.GetLocalization( "nodeinfo" ), node, distanceInMeters)
      angle = -atan2(dx, dy)
    end
    return description, angle
end

function HarvestRoute.InitTracker()
  if isActive then
      HarvestRouteButton:SetText(HarvestRoute.GetLocalization( "buttonstoptracker" ))
      HarvestRouteTrackerButton:SetText(HarvestRoute.GetLocalization( "buttonstoptracker" ))
      
      HarvestRouteTrackerActive:SetText( HarvestRoute.GetLocalization( "trackeractive" ) )
      
      HarvestRouteTrackerNearestNodeTitle:SetHidden( false )
      HarvestRouteTrackerNearestNode:SetHidden( false )
  else
      HarvestRouteButton:SetText(HarvestRoute.GetLocalization( "buttonstarttracker" ))
      HarvestRouteTrackerButton:SetText(HarvestRoute.GetLocalization( "buttonstarttracker" ))
      
      HarvestRouteTrackerActive:SetText( HarvestRoute.GetLocalization( "trackerinactive" ) )
      
      HarvestRouteTrackerNearestNodeTitle:SetHidden( true )
      HarvestRouteTrackerNearestNode:SetHidden( true )
      HarvestRouteTrackerNearestArrow:SetHidden( true )
      
      HarvestRouteTrackerLastPathNodeTitle:SetHidden( true )
      HarvestRouteTrackerLastPathNode:SetHidden( true )
      HarvestRouteTrackerPathArrow:SetHidden( true )
  end
end

function HarvestRoute.UpdateTracker()
    -- HarvestRoute.debug('UpdateTracker')
    if not HarvestRoute.savedVars.enableTrackerWindow then
      if isTrackerVisible then 
        HarvestRoute.SetTrackerHidden( true )
      end
      return 
    end
    if not isTrackerVisible then 
      HarvestRoute.debug('tracker not visible')
      return 
    end
    if isActive then
      nearestText, nearestAngle = HarvestRoute.GetNodeDescription(closestOutOfPathId)
      HarvestRouteTrackerNearestNode:SetText( nearestText )
      if nearestAngle then
        HarvestRouteTrackerNearestArrow:SetHidden(false)
        HarvestRouteTrackerNearestArrow:SetTextureRotation(-(nearestAngle + GetPlayerCameraHeading()), 0.5, 0.5)
      else
        HarvestRouteTrackerNearestArrow:SetHidden(true)
      end
    end
    if Farm.path then
      num = Farm.path.numNodes
      length = zo_round(Farm.path.length * 10) / 10
      infotext = zo_strformat( HarvestRoute.GetLocalization( "pathinfo" ), num, length)
      HarvestRouteTrackerPathInfo:SetText( infotext )
      if isActive then
        HarvestRouteTrackerLastPathNodeTitle:SetHidden( false )
        HarvestRouteTrackerLastPathNode:SetHidden( false )
        pathText, pathAngle = HarvestRoute.GetNodeDescription(pathNodeId)
        HarvestRouteTrackerLastPathNode:SetText( pathText )
        if pathAngle then
          HarvestRouteTrackerPathArrow:SetHidden(false)
          HarvestRouteTrackerPathArrow:SetTextureRotation(-(pathAngle + GetPlayerCameraHeading()), 0.5, 0.5)
        else
          HarvestRouteTrackerPathArrow:SetHidden(true)
        end
       end
    else
      HarvestRouteTrackerPathInfo:SetText( HarvestRoute.GetLocalization( "pathinfomissing" ) )
      HarvestRouteTrackerLastPathNodeTitle:SetHidden( true )
      HarvestRouteTrackerLastPathNode:SetHidden( true )
      HarvestRouteTrackerPathArrow:SetHidden( true )
    end
    
end

function HarvestRoute.debug(text)
  --CHAT_SYSTEM:AddMessage(text)
end 

EVENT_MANAGER:RegisterForEvent("HarvestRoute", EVENT_ADD_ON_LOADED, initialize)