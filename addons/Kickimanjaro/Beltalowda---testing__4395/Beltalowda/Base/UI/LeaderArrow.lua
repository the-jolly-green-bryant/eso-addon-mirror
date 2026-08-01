-- Beltalowda - Leader Arrow Module (Follow The Crown Arrow)
-- Ported from RdK Group Tool by @s0rdrak (PC / EU)
-- Shows a 2D arrow pointing toward the group leader on screen

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.LeaderArrow = Beltalowda.UI.LeaderArrow or {}

local LeaderArrow = Beltalowda.UI.LeaderArrow
local ADDON_NAME = "BeltalowdaLeaderArrow"

-- Module state
LeaderArrow.state = {}
LeaderArrow.state.initialized = false
LeaderArrow.state.registeredConsumers = false
LeaderArrow.state.registeredActivationConsumers = false
LeaderArrow.state.menuHidden = false
LeaderArrow.state.pvpHidden = false

LeaderArrow.controls = {}

-- Constants
LeaderArrow.config = {}
LeaderArrow.config.updateInterval = 10         -- milliseconds
LeaderArrow.config.minDistance = 8              -- meters — arrow hidden when closer than this
LeaderArrow.config.maxDistance = 40             -- meters — scaling cap
LeaderArrow.config.arrowSize = 48              -- pixels
LeaderArrow.config.orbitRadius = 65            -- pixels from screen center (reticle mode)
LeaderArrow.config.fixedOffsetY = 65           -- pixels below screen center (fixed mode)
LeaderArrow.config.opacity = 0.8              -- fixed alpha
LeaderArrow.config.fadeStartDistance = 8        -- meters — begin fading in
LeaderArrow.config.fadeEndDistance = 12         -- meters — fully visible
LeaderArrow.config.texture = "Beltalowda/Art/Arrow/arrow.dds"

-- Mode constants
LeaderArrow.modes = {}
LeaderArrow.modes.RETICLE = "reticle"
LeaderArrow.modes.FIXED = "fixed"

local wm = GetWindowManager()
local logger = nil

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
    Normalize angle to [-pi, pi] range
    Matches RdK's NormalizeAngle utility
]]--
local function NormalizeAngle(angle)
    if angle < -math.pi then return angle + 2 * math.pi end
    if angle > math.pi then return angle - 2 * math.pi end
    return angle
end

--[[
    Get default settings
]]--
function LeaderArrow.GetDefaults()
    return {
        enabled = false,
        mode = LeaderArrow.modes.RETICLE,
        fixedPositionX = nil,  -- nil = use default center offset
        fixedPositionY = nil,
    }
end

--[[
    Set menu-hidden state (called by centralized layer handler)
]]--
function LeaderArrow.SetMenuHidden(hidden)
    LeaderArrow.state.menuHidden = hidden
    if hidden then
        if LeaderArrow.controls.TLW_Reticle then
            LeaderArrow.controls.TLW_Reticle:SetHidden(true)
        end
        if LeaderArrow.controls.TLW_Fixed then
            LeaderArrow.controls.TLW_Fixed:SetHidden(true)
        end
    end
end

function LeaderArrow.SetPvPHidden(hidden)
    LeaderArrow.state.pvpHidden = hidden
    if hidden then
        if LeaderArrow.controls.TLW_Reticle then
            LeaderArrow.controls.TLW_Reticle:SetHidden(true)
        end
        if LeaderArrow.controls.TLW_Fixed then
            LeaderArrow.controls.TLW_Fixed:SetHidden(true)
        end
    end
end

--[[
    Initialize the arrow controls
]]--
function LeaderArrow.Initialize()
    if LeaderArrow.state.initialized then return end

    -- Create module logger if available
    if Beltalowda.Logger and Beltalowda.Logger.CreateModuleLogger then
        logger = Beltalowda.Logger.CreateModuleLogger("LeaderArrow")
    end

    Log("Info", "Initializing leader arrow module")

    -- Ensure saved vars structure exists
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.leaderArrow = BeltalowdaVars.leaderArrow or {}

    -- Apply defaults if not set
    local defaults = LeaderArrow.GetDefaults()
    if BeltalowdaVars.leaderArrow.enabled == nil then
        BeltalowdaVars.leaderArrow.enabled = defaults.enabled
    end
    if BeltalowdaVars.leaderArrow.mode == nil then
        BeltalowdaVars.leaderArrow.mode = defaults.mode
    end

    local size = LeaderArrow.config.arrowSize

    -- Create Reticle mode TLW + texture
    LeaderArrow.controls.TLW_Reticle = wm:CreateTopLevelWindow(ADDON_NAME .. "_TLW_Reticle")
    LeaderArrow.controls.TLW_Reticle:SetDimensions(size, size)
    LeaderArrow.controls.TLW_Reticle:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    LeaderArrow.controls.TLW_Reticle:SetClampedToScreen(true)
    LeaderArrow.controls.TLW_Reticle:SetDrawLayer(0)
    LeaderArrow.controls.TLW_Reticle:SetDrawLevel(0)
    LeaderArrow.controls.TLW_Reticle:SetHidden(true)

    LeaderArrow.controls.reticle = wm:CreateControl(ADDON_NAME .. "_Reticle", LeaderArrow.controls.TLW_Reticle, CT_TEXTURE)
    LeaderArrow.controls.reticle:SetAnchor(TOPLEFT, LeaderArrow.controls.TLW_Reticle, TOPLEFT, 0, 0)
    LeaderArrow.controls.reticle:SetDimensions(size, size)
    LeaderArrow.controls.reticle:SetTexture(LeaderArrow.config.texture)
    LeaderArrow.controls.reticle:SetColor(1, 1, 1, 1)

    -- Create Fixed mode TLW + texture (draggable)
    LeaderArrow.controls.TLW_Fixed = wm:CreateTopLevelWindow(ADDON_NAME .. "_TLW_Fixed")
    LeaderArrow.controls.TLW_Fixed:SetDimensions(size, size)
    LeaderArrow.controls.TLW_Fixed:SetClampedToScreen(true)
    LeaderArrow.controls.TLW_Fixed:SetDrawLayer(0)
    LeaderArrow.controls.TLW_Fixed:SetDrawLevel(0)
    LeaderArrow.controls.TLW_Fixed:SetHidden(true)
    LeaderArrow.controls.TLW_Fixed:SetMovable(true)
    LeaderArrow.controls.TLW_Fixed:SetMouseEnabled(true)

    -- Position from saved vars or default to screen center offset
    LeaderArrow.controls.TLW_Fixed:ClearAnchors()
    if BeltalowdaVars.leaderArrow.fixedPositionX and BeltalowdaVars.leaderArrow.fixedPositionY then
        LeaderArrow.controls.TLW_Fixed:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
            BeltalowdaVars.leaderArrow.fixedPositionX, BeltalowdaVars.leaderArrow.fixedPositionY)
    else
        LeaderArrow.controls.TLW_Fixed:SetAnchor(CENTER, GuiRoot, CENTER, 0, LeaderArrow.config.fixedOffsetY)
    end

    -- Save position when dragged
    LeaderArrow.controls.TLW_Fixed:SetHandler("OnMoveStop", function(control)
        BeltalowdaVars.leaderArrow.fixedPositionX = control:GetLeft()
        BeltalowdaVars.leaderArrow.fixedPositionY = control:GetTop()
        Log("Info", string.format("Fixed arrow position saved: X=%d Y=%d",
            BeltalowdaVars.leaderArrow.fixedPositionX, BeltalowdaVars.leaderArrow.fixedPositionY))
    end)

    LeaderArrow.controls.fixed = wm:CreateControl(ADDON_NAME .. "_Fixed", LeaderArrow.controls.TLW_Fixed, CT_TEXTURE)
    LeaderArrow.controls.fixed:SetAnchor(TOPLEFT, LeaderArrow.controls.TLW_Fixed, TOPLEFT, 0, 0)
    LeaderArrow.controls.fixed:SetDimensions(size, size)
    LeaderArrow.controls.fixed:SetTexture(LeaderArrow.config.texture)
    LeaderArrow.controls.fixed:SetColor(1, 1, 1, 1)

    LeaderArrow.state.initialized = true
    LeaderArrow.SetEnabled(BeltalowdaVars.leaderArrow.enabled)

    Log("Info", "Leader arrow module initialized successfully")
    return true
end

--[[
    Set enabled state
]]--
function LeaderArrow.SetEnabled(value)
    if not LeaderArrow.state.initialized or value == nil then return end

    BeltalowdaVars.leaderArrow.enabled = value

    if value == true then
        if not LeaderArrow.state.registeredConsumers then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, LeaderArrow.OnPlayerActivated)
            LeaderArrow.state.registeredConsumers = true
        end
    else
        if LeaderArrow.state.registeredConsumers then
            EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
            LeaderArrow.state.registeredConsumers = false
        end
    end

    LeaderArrow.OnPlayerActivated()
end

--[[
    Handle player activation (zone change, login, /reloadui)
]]--
function LeaderArrow.OnPlayerActivated(eventCode, initial)
    if not BeltalowdaVars or not BeltalowdaVars.leaderArrow then
        return
    end

    if BeltalowdaVars.leaderArrow.enabled == true then
        if not LeaderArrow.state.registeredActivationConsumers then
            EVENT_MANAGER:RegisterForUpdate(ADDON_NAME, LeaderArrow.config.updateInterval, LeaderArrow.UiLoop)
            LeaderArrow.state.registeredActivationConsumers = true
        end
    else
        if LeaderArrow.state.registeredActivationConsumers then
            EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME)
            LeaderArrow.state.registeredActivationConsumers = false
        end
        if LeaderArrow.controls.TLW_Reticle then
            LeaderArrow.controls.TLW_Reticle:SetHidden(true)
        end
        if LeaderArrow.controls.TLW_Fixed then
            LeaderArrow.controls.TLW_Fixed:SetHidden(true)
        end
    end
end

--[[
    Main UI update loop — computes distance and rotation to leader,
    then positions and rotates the arrow accordingly.
]]--
function LeaderArrow.UiLoop()
    local drawArrow = false
    local rotation = 0
    local distance = 0

    if not BeltalowdaVars or not BeltalowdaVars.leaderArrow then
        return
    end

    if BeltalowdaVars.leaderArrow.enabled == true and IsUnitGrouped("player") then
        -- Find the leader
        local leader = nil
        local leaderZoneIndex = nil
        local groupSize = GetGroupSize()

        for i = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag and IsUnitGroupLeader(unitTag) then
                leader = unitTag
                leaderZoneIndex = GetUnitZoneIndex(unitTag)
                break
            end
        end

        if leader ~= nil then
            -- Must not be the player and must be in same zone
            if not AreUnitsEqual(leader, "player") and
               leaderZoneIndex ~= nil and
               leaderZoneIndex == GetUnitZoneIndex("player") then

                -- Get raw world positions (centimeters)
                local _, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
                local _, leaderX, leaderY, leaderZ = GetUnitRawWorldPosition(leader)

                if playerX and leaderX and playerX ~= 0 and leaderX ~= 0 then
                    -- Distance in meters (raw coords are centimeters)
                    local dx = playerX - leaderX
                    local dz = playerZ - leaderZ
                    distance = math.sqrt(dx * dx + dz * dz) / 100

                    if distance >= LeaderArrow.config.minDistance then
                        drawArrow = true

                        -- Rotation relative to camera heading
                        -- Uses the same formula as RdK's OnUpdateLeader:
                        --   rotation = 2pi - NormalizeAngle(cameraHeading - atan2(dx, dz))
                        -- where dx/dz are player-to-leader deltas (player minus leader)
                        local cameraHeading = NormalizeAngle(GetPlayerCameraHeading())
                        rotation = (math.pi * 2) - NormalizeAngle(cameraHeading - math.atan2(dx, dz))
                    end
                end
            end
        end
    end

    -- Hide when menus are open
    if LeaderArrow.state.menuHidden or LeaderArrow.state.pvpHidden then
        drawArrow = false
    end

    local mode = BeltalowdaVars.leaderArrow.mode or LeaderArrow.modes.RETICLE

    if drawArrow then
        -- Compute opacity: fade in between minDistance and fadeEndDistance
        local alpha = LeaderArrow.config.opacity
        if distance < LeaderArrow.config.fadeEndDistance then
            local fadeRange = LeaderArrow.config.fadeEndDistance - LeaderArrow.config.fadeStartDistance
            if fadeRange > 0 then
                alpha = LeaderArrow.config.opacity * (distance - LeaderArrow.config.fadeStartDistance) / fadeRange
                if alpha < 0 then alpha = 0 end
                if alpha > LeaderArrow.config.opacity then alpha = LeaderArrow.config.opacity end
            end
        end

        local size = LeaderArrow.config.arrowSize

        -- Apply rotation to both textures
        LeaderArrow.controls.reticle:SetTextureRotation(rotation)
        LeaderArrow.controls.fixed:SetTextureRotation(rotation)

        -- Apply opacity
        LeaderArrow.controls.reticle:SetColor(1, 1, 1, alpha)
        LeaderArrow.controls.fixed:SetColor(1, 1, 1, alpha)

        if mode == LeaderArrow.modes.RETICLE then
            -- Orbit around screen center: position the TLW based on rotation
            local orbitRadius = LeaderArrow.config.orbitRadius + size / 2
            local distanceX = math.sin(math.pi + rotation) * orbitRadius
            local distanceY = math.cos(math.pi + rotation) * orbitRadius

            LeaderArrow.controls.TLW_Reticle:ClearAnchors()
            LeaderArrow.controls.TLW_Reticle:SetAnchor(CENTER, GuiRoot, CENTER, distanceX, distanceY)
            LeaderArrow.controls.TLW_Reticle:SetHidden(false)
            LeaderArrow.controls.TLW_Fixed:SetHidden(true)
        elseif mode == LeaderArrow.modes.FIXED then
            -- Fixed position — only rotation changes
            LeaderArrow.controls.TLW_Fixed:SetHidden(false)
            LeaderArrow.controls.TLW_Reticle:SetHidden(true)
        end
    else
        LeaderArrow.controls.TLW_Reticle:SetHidden(true)
        LeaderArrow.controls.TLW_Fixed:SetHidden(true)
    end
end

-- ============================================================================
-- Settings Panel Controls (called from BeltalowdaSettings.lua)
-- ============================================================================

function LeaderArrow.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFLeader Arrow|r",
            tooltip = "Configure the Follow The Crown arrow that points toward the group leader",
            controls = {
                {
                    type = "description",
                    text = "Shows a 2D arrow on screen pointing toward the group leader. The arrow only appears when you are 8 metres or more from the crown. Ported from RdK Group Tool.",
                    width = "full",
                },
                -- Enable Leader Arrow
                {
                    type = "checkbox",
                    name = "Enable Leader Arrow",
                    tooltip = "Show an arrow pointing toward the group leader when you are far from the crown",
                    getFunc = function() return LeaderArrow.GetEnabled() end,
                    setFunc = function(value) LeaderArrow.SetEnabled(value) end,
                    width = "full",
                    default = false,
                },
                -- Arrow Mode
                {
                    type = "dropdown",
                    name = "Arrow Mode",
                    tooltip = "Reticle: arrow orbits around your crosshair, pointing toward the leader.\nFixed: arrow stays at a fixed position below screen center, only rotating.",
                    choices = {"Reticle", "Fixed"},
                    getFunc = function()
                        local mode = BeltalowdaVars.leaderArrow.mode or LeaderArrow.modes.RETICLE
                        if mode == LeaderArrow.modes.FIXED then return "Fixed" end
                        return "Reticle"
                    end,
                    setFunc = function(value)
                        if value == "Fixed" then
                            BeltalowdaVars.leaderArrow.mode = LeaderArrow.modes.FIXED
                        else
                            BeltalowdaVars.leaderArrow.mode = LeaderArrow.modes.RETICLE
                        end
                    end,
                    width = "full",
                    default = "Reticle",
                },
                -- Reset Fixed Position
                {
                    type = "button",
                    name = "Reset Fixed Position",
                    tooltip = "Reset the fixed-mode arrow back to its default position (below screen center). Only applies to Fixed mode.",
                    func = function()
                        BeltalowdaVars.leaderArrow.fixedPositionX = nil
                        BeltalowdaVars.leaderArrow.fixedPositionY = nil
                        if LeaderArrow.controls.TLW_Fixed then
                            LeaderArrow.controls.TLW_Fixed:ClearAnchors()
                            LeaderArrow.controls.TLW_Fixed:SetAnchor(CENTER, GuiRoot, CENTER, 0, LeaderArrow.config.fixedOffsetY)
                        end
                    end,
                    width = "full",
                },
            },
        },
    }
end

-- Settings getters for external use

function LeaderArrow.GetEnabled()
    if not BeltalowdaVars or not BeltalowdaVars.leaderArrow then
        return false
    end
    return BeltalowdaVars.leaderArrow.enabled
end

-- ============================================================================
-- Slash command
-- ============================================================================

SLASH_COMMANDS["/beltalowdaarrow"] = function(args)
    args = string.lower(args or "")

    if args == "on" then
        LeaderArrow.SetEnabled(true)
        d("|c00FF00[Beltalowda]|r Leader arrow enabled")
    elseif args == "off" then
        LeaderArrow.SetEnabled(false)
        d("|cFF0000[Beltalowda]|r Leader arrow disabled")
    elseif args == "toggle" then
        LeaderArrow.SetEnabled(not LeaderArrow.GetEnabled())
        if LeaderArrow.GetEnabled() then
            d("|c00FF00[Beltalowda]|r Leader arrow enabled")
        else
            d("|cFF0000[Beltalowda]|r Leader arrow disabled")
        end
    elseif args == "status" then
        d("|cFFFF00[Beltalowda] Leader Arrow:|r")
        d("  Enabled: " .. tostring(LeaderArrow.GetEnabled()))
        d("  Mode: " .. tostring(BeltalowdaVars and BeltalowdaVars.leaderArrow and BeltalowdaVars.leaderArrow.mode or "reticle"))
        d("  In group: " .. tostring(IsUnitGrouped("player")))
    else
        d("|cFFFF00[Beltalowda] Leader Arrow Commands:|r")
        d("  /beltalowdaarrow on|off|toggle - Enable/disable")
        d("  /beltalowdaarrow status - Show status")
        d("Status: " .. (LeaderArrow.GetEnabled() and "|c00FF00ON|r" or "|cFF0000OFF|r"))
    end
end
