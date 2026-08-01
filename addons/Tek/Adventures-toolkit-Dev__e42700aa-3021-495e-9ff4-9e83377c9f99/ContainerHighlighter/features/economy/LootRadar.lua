-- ============================================
-- LOOT RADAR MODULE (3D container markers)
-- ============================================

NWT.nearbyContainers = {}
NWT.radarPins = {}
NWT.activePins = {}
NWT.radarPinsInitialized = false

local RADAR_PIN_SIZE = 50

local function InitRadarPins()
    if not NWT.radarPinsInitialized then
        if not NWT_WorldPins then return end
        
        NWT_WorldPins:Create3DRenderSpace()
        Set3DRenderSpaceToCurrentCamera("NWT_WorldPins")
        NWT_WorldPins:SetHidden(false)
        
        for i = 1, 20 do
            local pin = CreateControlFromVirtual("NWT_RadarPin", NWT_WorldPins, "NWT_RadarPin", i)
            pin:Create3DRenderSpace()
            pin:Set3DRenderSpaceSystem(GUI_RENDER_3D_SPACE_SYSTEM_CONTROL)
            pin:Set3DRenderSpaceUsesDepthBuffer(false)
            
            local icon = pin:GetNamedChild("Icon")
            icon:Create3DRenderSpace()
            icon:Set3DRenderSpaceSystem(GUI_RENDER_3D_SPACE_SYSTEM_CONTROL)
            icon:Set3DRenderSpaceUsesDepthBuffer(false)
            icon:Set3DLocalDimensions(RADAR_PIN_SIZE, RADAR_PIN_SIZE)
            
            pin:SetHidden(true)
            table.insert(NWT.radarPins, pin)
        end
        NWT.radarPinsInitialized = true
        -- Startup message removed
    end
end

function NWT.UpdateRadarPins()
    if not NWT.isAuthorized then return end
    InitRadarPins()
    
    local zoneId, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    local containers = NWT.savedVars.lootRadar.containers[zoneId] or {}
    
    local nearby = {}
    local maxDistSq = 5000 * 5000
    
    for key, data in pairs(containers) do
        local dx = data.x - playerX
        local dy = data.y - playerY
        local dz = data.z - playerZ
        local distSq = dx*dx + dy*dy + dz*dz
        
        if distSq < maxDistSq then
            data.distSq = distSq
            table.insert(nearby, data)
        end
    end
    
    table.sort(nearby, function(a, b) return a.distSq < b.distSq end)
    
    local heading = GetPlayerCameraHeading()
    for i = 1, 20 do
        local pin = NWT.radarPins[i]
        local data = nearby[i]
        
        if data then
            local rx, ry, rz = WorldPositionToGuiRender3DPosition(data.x, playerY, data.z)
            pin:Set3DRenderSpaceOrigin(rx, ry, rz)
            pin:Set3DRenderSpaceOrientation(0, heading, 0)
            
            local icon = pin:GetNamedChild("Icon")
            icon:Set3DLocalDimensions(RADAR_PIN_SIZE, RADAR_PIN_SIZE)
            
            if data.isOwned then icon:SetColor(1, 0, 0, 1)
            elseif data.type == "chest" or data.type == "heavysack" or data.type == "trove" then icon:SetColor(1, 0.8, 0, 1)
            else icon:SetColor(0, 1, 0, 1) end
            
            pin:SetHidden(false)
        else
            if pin then pin:SetHidden(true) end
        end
    end
end

function NWT.StartRadarUpdates()
    EVENT_MANAGER:RegisterForUpdate("ContainerHighlighter_RadarUpdate", 100, function()
        NWT.UpdateRadarPins()
    end)
end

local function GetContainerType(name, action)
    name = name:lower()
    if name:find("chest") or name:find("strongbox") then return "chest"
    elseif name:find("sack") or name:find("bag") then return "sack"
    elseif name:find("heavy sack") then return "heavysack"
    elseif name:find("barrel") or name:find("crate") or name:find("basket") then return "crate"
    elseif name:find("thieves trove") then return "trove"
    else return "other" end
end

function NWT.OnReticleTargetChanged()
    if not NWT.isAuthorized then return end
    
    local action, name, _, isOwned = GetGameCameraInteractableActionInfo()
    if not name or name == "" then return end
    
    local actionLower = action:lower()
    if actionLower:find("search") or actionLower:find("steal") then
        local zoneId, worldX, worldY, worldZ = GetUnitRawWorldPosition("player")
        local containerType = GetContainerType(name, actionLower)
        local key = string.format("%d_%d_%d", math.floor(worldX/100), math.floor(worldY/100), math.floor(worldZ/100))
        
        if not NWT.savedVars.lootRadar.containers[zoneId] then NWT.savedVars.lootRadar.containers[zoneId] = {} end
        
        if not NWT.savedVars.lootRadar.containers[zoneId][key] then
            NWT.savedVars.lootRadar.containers[zoneId][key] = {
                name = name, type = containerType, isOwned = isOwned,
                x = worldX, y = worldY, z = worldZ, discovered = GetTimeStamp()
            }
            NWT.savedVars.lootRadar.discoveryCount = NWT.savedVars.lootRadar.discoveryCount + 1
NWT.Debug("|c00FF00[Loot Radar]|r Discovered: " .. name)
            PlaySound(SOUNDS.OBJECTIVE_COMPLETED)
        end
    end
end

function NWT.UpdateNearbyContainers()
    local zoneId, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    local containers = NWT.savedVars.lootRadar.containers[zoneId] or {}
    
    NWT.nearbyContainers = {}
    local maxDistance = 3000
    
    for _, data in pairs(containers) do
        local dx, dy, dz = data.x - playerX, data.y - playerY, data.z - playerZ
        local distSq = dx*dx + dy*dy + dz*dz
        if distSq < (maxDistance * maxDistance) then
            data.distance = math.sqrt(distSq) / 100
            table.insert(NWT.nearbyContainers, data)
        end
    end
    table.sort(NWT.nearbyContainers, function(a, b) return a.distance < b.distance end)
end
