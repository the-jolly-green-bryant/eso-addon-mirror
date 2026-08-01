-- Beltalowda - Leader Beam Module (Follow The Crown Beam)
-- Ported from RdK Group Tool by @s0rdrak (PC / EU)
-- Shows a beam on the group leader for easy tracking

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.LeaderBeam = Beltalowda.UI.LeaderBeam or {}

local LeaderBeam = Beltalowda.UI.LeaderBeam
local ADDON_NAME = "BeltalowdaLeaderBeam"

-- Access utility modules
local Beams = Beltalowda.Util.Beams
local Objects3D = Beltalowda.Util.Objects3D

-- Module state
LeaderBeam.state = {}
LeaderBeam.state.initialized = false
LeaderBeam.state.registeredConsumers = false
LeaderBeam.state.registeredActivationConsumers = false
LeaderBeam.state.textureRegistered = false
LeaderBeam.state.menuHidden = false
LeaderBeam.state.pvpHidden = false

LeaderBeam.controls = {}
LeaderBeam.config = {}
LeaderBeam.config.updateInterval = 10  -- milliseconds
LeaderBeam.config.maxDistance = 200  -- meters

--[[
    Set menu-hidden state (called by centralized layer handler)
]]--
function LeaderBeam.SetMenuHidden(hidden)
    LeaderBeam.state.menuHidden = hidden
    -- If hiding, immediately hide the beam
    if hidden and LeaderBeam.controls and LeaderBeam.controls.beam then
        LeaderBeam.controls.beam:SetHidden(true)
    end
end

function LeaderBeam.SetPvPHidden(hidden)
    LeaderBeam.state.pvpHidden = hidden
    if hidden and LeaderBeam.controls and LeaderBeam.controls.beam then
        LeaderBeam.controls.beam:SetHidden(true)
    end
end

local wm = GetWindowManager()
local logger = nil  -- Will be initialized in Initialize()

--[[
    Helper function for logging
]]--
local function Log(level, message)
    if logger then
        if level == "Debug" then
            logger:Debug(message)
        elseif level == "Info" then
            logger:Info(message)
        elseif level == "Error" then
            logger:Error(message)
        end
    end
end

--[[
    Get default settings
]]--
function LeaderBeam.GetDefaults()
    local defaults = {}
    defaults.enabled = false
    defaults.beamThickness = Beams.DEFAULT_THICKNESS
    defaults.color = {}
    defaults.color.r = 0
    defaults.color.g = 0.5
    defaults.color.b = 1
    defaults.color.a = 0.75
    return defaults
end

--[[
    Initialize the beam control
]]--
function LeaderBeam.Initialize()
    if LeaderBeam.state.initialized then return end
    -- Create module logger if available
    if Beltalowda.Logger and Beltalowda.Logger.CreateModuleLogger then
        logger = Beltalowda.Logger.CreateModuleLogger("LeaderBeam")
    end
    
    Log("Info", "Initializing leader beam module")
    
    -- Ensure saved vars structure exists
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.leaderBeam = BeltalowdaVars.leaderBeam or {}
    
    -- Apply defaults if not set
    local defaults = LeaderBeam.GetDefaults()
    if BeltalowdaVars.leaderBeam.enabled == nil then
        BeltalowdaVars.leaderBeam.enabled = defaults.enabled
    end
    if BeltalowdaVars.leaderBeam.beamThickness == nil then
        -- Migrate from old selectedBeam if present
        if BeltalowdaVars.leaderBeam.selectedBeam then
            local old = BeltalowdaVars.leaderBeam.selectedBeam
            BeltalowdaVars.leaderBeam.beamThickness = (old >= 1 and old <= 4) and old or defaults.beamThickness
            BeltalowdaVars.leaderBeam.selectedBeam = nil
        else
            BeltalowdaVars.leaderBeam.beamThickness = defaults.beamThickness
        end
    end
    if BeltalowdaVars.leaderBeam.color == nil then
        BeltalowdaVars.leaderBeam.color = defaults.color
    end
    
    -- Create the beam control as a child of the 3D parent
    LeaderBeam.controls.beam = wm:CreateControl(nil, Objects3D.GetDefaultParent(), CT_TEXTURE)
    LeaderBeam.controls.beam:Create3DRenderSpace()
    LeaderBeam.controls.beam:Set3DLocalDimensions(1, 256)
    LeaderBeam.controls.beam:SetDrawLevel(3)
    LeaderBeam.controls.beam:SetHidden(true)
    LeaderBeam.controls.beam:Set3DRenderSpaceUsesDepthBuffer(true)
    
    Log("Info", "Beam control created successfully")
    
    LeaderBeam.state.initialized = true
    LeaderBeam.AdjustTexture()
    LeaderBeam.AdjustColor()
    LeaderBeam.SetEnabled(BeltalowdaVars.leaderBeam.enabled)
    
    Log("Info", "Leader beam module initialized successfully")
    return true
end

--[[
    Adjust beam texture based on settings
]]--
function LeaderBeam.AdjustTexture()
    if not LeaderBeam.controls.beam then return end
    
    if not BeltalowdaVars or not BeltalowdaVars.leaderBeam then
        Log("Error", "Cannot adjust texture - settings not initialized")
        return
    end
    
    local beam = Beams.GetBeamByThickness(BeltalowdaVars.leaderBeam.beamThickness)
    if beam then
        LeaderBeam.controls.beam:SetTexture(beam.texture)
        LeaderBeam.controls.beam:Set3DLocalDimensions(beam.width, beam.height)
        LeaderBeam.controls.beam:Set3DRenderSpaceUsesDepthBuffer(true)
        Log("Info", "Texture set to thickness " .. tostring(BeltalowdaVars.leaderBeam.beamThickness))
    else
        Log("Error", "Failed to get beam for thickness: " .. tostring(BeltalowdaVars.leaderBeam.beamThickness))
    end
end

--[[
    Adjust beam color based on settings
]]--
function LeaderBeam.AdjustColor()
    if not LeaderBeam.controls.beam then 
        Log("Error", "Cannot adjust color - beam control is nil")
        return 
    end
    
    if not BeltalowdaVars or not BeltalowdaVars.leaderBeam or not BeltalowdaVars.leaderBeam.color then
        Log("Error", "Cannot adjust color - settings not initialized")
        return
    end
    
    local color = BeltalowdaVars.leaderBeam.color
    LeaderBeam.controls.beam:SetColor(color.r, color.g, color.b, color.a)
    Log("Debug", string.format("Color set to R=%.2f G=%.2f B=%.2f A=%.2f", color.r, color.g, color.b, color.a))
end

--[[
    Set enabled state
]]--
function LeaderBeam.SetEnabled(value)
    if not LeaderBeam.state.initialized or value == nil then return end
    
    BeltalowdaVars.leaderBeam.enabled = value
    
    if value == true then
        if not LeaderBeam.state.registeredConsumers then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, LeaderBeam.OnPlayerActivated)
            LeaderBeam.state.registeredConsumers = true
        end
    else
        if LeaderBeam.state.registeredConsumers then
            EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
            LeaderBeam.state.registeredConsumers = false
        end
    end
    
    
    LeaderBeam.OnPlayerActivated()
end

--[[
    Handle player activation (zone change, login, /reloadui)
]]--
function LeaderBeam.OnPlayerActivated(eventCode, initial)
    -- Defensive check
    if not BeltalowdaVars or not BeltalowdaVars.leaderBeam then
        return
    end
    
    if BeltalowdaVars.leaderBeam.enabled == true then
        
        if not LeaderBeam.state.registeredActivationConsumers then
            EVENT_MANAGER:RegisterForUpdate(ADDON_NAME, LeaderBeam.config.updateInterval, LeaderBeam.UiLoop)
            LeaderBeam.state.registeredActivationConsumers = true
        end
    else
        if LeaderBeam.state.registeredActivationConsumers then
            EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME)
            LeaderBeam.state.registeredActivationConsumers = false
        end
        LeaderBeam.controls.beam:SetHidden(true)
        if LeaderBeam.state.textureRegistered then
            LeaderBeam.state.textureRegistered = false
            Objects3D.UnregisterTextureControl(LeaderBeam.controls.beam)
        end
    end
end

--[[
    Main UI update loop
]]--
function LeaderBeam.UiLoop()
    local drawBeam = false
    
    -- Defensive check
    if not BeltalowdaVars or not BeltalowdaVars.leaderBeam then
        return
    end
    
    if BeltalowdaVars.leaderBeam.enabled == true then
        
        if IsUnitGrouped("player") then
            -- Find the leader
            local leader = nil
            local leaderZoneIndex = nil
            local groupSize = GetGroupSize()
            
            for i = 1, groupSize do
                local unitTag = GetGroupUnitTagByIndex(i)
                if unitTag and IsUnitGroupLeader(unitTag) then
                    leader = unitTag
                    leaderZoneIndex = GetUnitZoneIndex(unitTag)
                    Log("Debug", "Found leader: " .. GetUnitName(unitTag))
                    break
                end
            end
            
            if leader ~= nil then
                -- Check if leader is not the player and is in same zone
                if not AreUnitsEqual(leader, "player") and 
                   leaderZoneIndex ~= nil and 
                   leaderZoneIndex == GetUnitZoneIndex("player") then
                    
                    drawBeam = true
                    local beam = Beams.GetBeamByThickness(BeltalowdaVars.leaderBeam.beamThickness)
                    
                    -- Get leader position using RAW world position (in centimeters)
                    local zoneId, worldX, worldY, worldZ = GetUnitRawWorldPosition(leader)
                    
                    if worldX and worldX ~= 0 then
                        -- Convert to GUI render space coordinates (handles coordinate system changes)
                        local guiX, guiY, guiZ = WorldPositionToGuiRender3DPosition(worldX, worldY + (beam.heightOffset * 100), worldZ)
                        
                        if guiX then
                            -- Position beam using GUI render space coordinates
                            LeaderBeam.controls.beam:Set3DRenderSpaceOrigin(guiX, guiY, guiZ)
                            
                            -- Orient beam based on camera heading
                            local heading = GetPlayerCameraHeading()
                            if heading > math.pi then
                                heading = heading - 2 * math.pi
                            end
                            LeaderBeam.controls.beam:Set3DRenderSpaceOrientation(0, heading, 0)
                            
                            Log("Debug", string.format("Beam positioned at GUI: X=%.2f Y=%.2f Z=%.2f, heading=%.2f", guiX, guiY, guiZ, heading))
                        else
                            drawBeam = false
                            Log("Debug", "Failed to convert world position to GUI render space")
                        end
                    else
                        drawBeam = false
                        Log("Debug", "Leader has no valid world position")
                    end
                else
                    if AreUnitsEqual(leader, "player") then
                        Log("Debug", "You are the leader - no beam shown")
                    elseif leaderZoneIndex == nil then
                        Log("Debug", "Leader zone index is nil")
                    else
                        Log("Debug", "Leader is in a different zone")
                    end
                end
            else
                Log("Debug", "No leader found in group")
            end
        else
            Log("Debug", "Not grouped")
        end
    end
    
    -- Hide beam when menus are open
    if LeaderBeam.state.menuHidden or LeaderBeam.state.pvpHidden then
        drawBeam = false
    end
    
    -- Show or hide beam based on conditions
    if drawBeam == true then
        LeaderBeam.controls.beam:SetHidden(false)
        if not LeaderBeam.state.textureRegistered then
            LeaderBeam.state.textureRegistered = true
            Objects3D.RegisterTextureControl(LeaderBeam.controls.beam)
            Log("Info", "Beam shown and registered")
        end
    else
        LeaderBeam.controls.beam:SetHidden(true)
        if LeaderBeam.state.textureRegistered then
            LeaderBeam.state.textureRegistered = false
            Objects3D.UnregisterTextureControl(LeaderBeam.controls.beam)
            Log("Debug", "Beam hidden and unregistered")
        end
    end
end

-- Settings getters/setters for LibAddonMenu integration

function LeaderBeam.GetEnabled()
    if not BeltalowdaVars or not BeltalowdaVars.leaderBeam then
        return false
    end
    return BeltalowdaVars.leaderBeam.enabled
end

function LeaderBeam.SetEnabled_WithRefresh(value)
    LeaderBeam.SetEnabled(value)
end

function LeaderBeam.GetThickness()
    if not BeltalowdaVars or not BeltalowdaVars.leaderBeam then
        return Beams.DEFAULT_THICKNESS
    end
    return BeltalowdaVars.leaderBeam.beamThickness or Beams.DEFAULT_THICKNESS
end

function LeaderBeam.SetThickness(value)
    if value ~= nil and BeltalowdaVars and BeltalowdaVars.leaderBeam then
        BeltalowdaVars.leaderBeam.beamThickness = value
        LeaderBeam.AdjustTexture()
    end
end

function LeaderBeam.GetColor()
    if not BeltalowdaVars or not BeltalowdaVars.leaderBeam or not BeltalowdaVars.leaderBeam.color then
        return 0, 0.5, 1, 0.75  -- Default blue
    end
    local c = BeltalowdaVars.leaderBeam.color
    return c.r, c.g, c.b, c.a
end

function LeaderBeam.SetColor(r, g, b, a)
    if not BeltalowdaVars or not BeltalowdaVars.leaderBeam then
        return
    end
    BeltalowdaVars.leaderBeam.color = BeltalowdaVars.leaderBeam.color or {}
    BeltalowdaVars.leaderBeam.color.r = r
    BeltalowdaVars.leaderBeam.color.g = g
    BeltalowdaVars.leaderBeam.color.b = b
    BeltalowdaVars.leaderBeam.color.a = a
    LeaderBeam.AdjustColor()
end

-- ============================================================================
-- Settings Panel Controls (called from BeltalowdaSettings.lua)
-- ============================================================================

function LeaderBeam.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFLeader Beam|r",
            tooltip = "Configure the Follow The Crown beam that shows on the group leader",
            controls = {
                {
                    type = "description",
                    text = "Shows a beam on the group leader for easy tracking. Ported from RdK Group Tool.",
                    width = "full",
                },
                -- Enable Leader Beam
                {
                    type = "checkbox",
                    name = "Enable Leader Beam",
                    tooltip = "Show a beam on the group leader for easy tracking",
                    getFunc = function() return LeaderBeam.GetEnabled() end,
                    setFunc = function(value) LeaderBeam.SetEnabled(value) end,
                    width = "full",
                    default = false,
                },
                -- Beam Thickness
                {
                    type = "slider",
                    name = "Beam Thickness",
                    tooltip = "Thickness of the leader beam",
                    min = 0.5,
                    max = 5.0,
                    step = 0.5,
                    getFunc = function() return LeaderBeam.GetThickness() end,
                    setFunc = function(value) LeaderBeam.SetThickness(value) end,
                    width = "full",
                    default = 1,
                },
                -- Beam Color
                {
                    type = "colorpicker",
                    name = "Beam Color",
                    tooltip = "Color of the leader beam",
                    getFunc = function() return LeaderBeam.GetColor() end,
                    setFunc = function(r, g, b, a) LeaderBeam.SetColor(r, g, b, a) end,
                    width = "full",
                },
            },
        },
    }
end

-- Slash command for quick toggle
SLASH_COMMANDS["/beltalowdabeam"] = function(args)
    args = string.lower(args or "")
    
    if args == "on" then
        LeaderBeam.SetEnabled(true)
        d("|c00FF00[Beltalowda]|r Leader beam enabled")
    elseif args == "off" then
        LeaderBeam.SetEnabled(false)
        d("|cFF0000[Beltalowda]|r Leader beam disabled")
    elseif args == "toggle" then
        LeaderBeam.SetEnabled(not LeaderBeam.GetEnabled())
        if LeaderBeam.GetEnabled() then
            d("|c00FF00[Beltalowda]|r Leader beam enabled")
        else
            d("|cFF0000[Beltalowda]|r Leader beam disabled")
        end
    elseif args == "status" then
        d("|cFFFF00[Beltalowda] Leader Beam:|r")
        d("  Enabled: " .. tostring(LeaderBeam.GetEnabled()))
        d("  Thickness: " .. tostring(LeaderBeam.GetThickness()))
        if BeltalowdaVars and BeltalowdaVars.leaderBeam and BeltalowdaVars.leaderBeam.color then
            local c = BeltalowdaVars.leaderBeam.color
            d(string.format("  Color: R=%.2f G=%.2f B=%.2f A=%.2f", c.r, c.g, c.b, c.a))
        end
        d("  In group: " .. tostring(IsUnitGrouped("player")))
    else
        d("|cFFFF00[Beltalowda] Leader Beam Commands:|r")
        d("  /beltalowdabeam on|off|toggle - Enable/disable")
        d("  /beltalowdabeam status - Show status")
        d("Status: " .. (LeaderBeam.GetEnabled() and "|c00FF00ON|r" or "|cFF0000OFF|r"))
    end
end
