--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local _logger = nil
local _settingsHandler = TGT_SettingsHandler

local _control = TGT_CenteredLeaderMarkerControl
local _isActive = false
local _leader = nil
local _player = { Tag = "player" }

--[[
	Table TGT_CenteredLeaderMarker
]]--
TGT_CenteredLeaderMarker = {}
TGT_CenteredLeaderMarker.__index = TGT_CenteredLeaderMarker

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	NormalizeAngle calculates angle
]]--
local function NormalizeAngle(s, c)
    if c == nil then c = s end
    if c > math.pi then return c - 2 * math.pi end
    if c < -math.pi then return c + 2 * math.pi end
    return c
end

--[[
	UpdatePlayer updates player entity position and angle
]]--
local function UpdatePlayer()
    -- The method will be called every frame by TGT_CenteredLeaderMarker.OnUpdateControl()

    _player.Name = GetUnitName(_player.Tag)
    _player.X, _player.Y, _player.Z = GetMapPlayerPosition(_player.Tag)
    _player.H = NormalizeAngle(GetPlayerCameraHeading())
end

--[[
	UpdateLeader updates leader entity position and leader Tag
]]--
local function UpdateLeader()
    -- The method will be called every frame by TGT_CenteredLeaderMarker.OnUpdateControl()

	local newLeader = GetGroupLeaderUnitTag()
    if (_leader == nil or _leader.Tag ~= newLeader) then
		_leader = { Tag = newLeader }
    end

    if (_leader.Name == _player.Name) then
		_leader = nil
	end

    if (_leader ~= nil) then
        _leader.X, _leader.Y, _leader.Z = GetMapPlayerPosition(_leader.Tag)
        _leader.Name = GetUnitName(_leader.Tag)
    end
end

--[[
	UpdateReticle updates position of reticle
]]--
local function UpdateReticle()
    -- The method will be called every frame by TGT_CenteredLeaderMarker.OnUpdateControl()
    -- Distance offset
    local distance = _settingsHandler.SavedVariables.CircleDistance
	local dx = _player.X - _leader.X
    local dy = _player.Y - _leader.Y
	
    if (_settingsHandler.SavedVariables.LeaderArrowDistance) then
		-- magic number 256 to make animation smoother (faster between 0-1, so you get early to max distance)
        local minDistance = _settingsHandler.SavedVariables.MinDistance
        local maxDistance = _settingsHandler.SavedVariables.MaxDistance
		local difference = math.sqrt((dx * dx) + (dy * dy))
		local relativeDistance = math.tanh(difference * 256)

        distance = distance + math.abs(minDistance + (maxDistance - minDistance) * relativeDistance)
    end

    local angle = NormalizeAngle(_player.H - math.atan2(dx, dy))

    local x = math.sin(math.pi - angle) * distance
    local y = math.cos(math.pi - angle) * distance

    _control:GetNamedChild("Texture"):ClearAnchors()
    _control:GetNamedChild("Texture"):SetAnchor(CENTER, _control, CENTER, x, y)
    _control:GetNamedChild("Texture"):SetTextureRotation((math.pi * 2) - angle)
end

--[[
	SetControlColor sets control color
]]--
local function SetControlColors(part)
    if (part == GROUP_LEADER) then
        local controlColor = _settingsHandler.SavedVariables.ModuleColors[part].ArrowColor
	    _control:GetNamedChild("Texture"):SetColor(controlColor.R, controlColor.G, controlColor.B, controlColor.A)
    end
end

--[[
	SetControlHidden sets hidden on control
]]--
local function SetControlHidden()
    local isActive = _settingsHandler.SavedVariables.IsLeaderArrowActive

    -- Only show if control is active, player is grouped and player is NOT the leader
    if (isActive and GetIsUnitGrouped() and IsUnitGroupLeader("player") == false) then
        _control:SetHidden(CurrentHudHiddenState())
    else
        _control:SetHidden(true)
    end
end

--[[
	SetControlActive sets isActive on control
]]--
local function SetControlActive()
    SetControlHidden()

    local isActive = _settingsHandler.SavedVariables.IsLeaderArrowActive
    
    if (_isActive ~= isActive) then
        _isActive = isActive

        if (isActive) then
            SetControlColors(GROUP_LEADER)

            CALLBACK_MANAGER:RegisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
        else
            CALLBACK_MANAGER:UnregisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
        end
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	OnUpdateControl updates position of reticle
]]--
function TGT_CenteredLeaderMarker.OnUpdateControl()
    -- If UI visible, the method will be called every frame
	if (GetIsUnitGrouped()) then
		UpdatePlayer()
		UpdateLeader()

		if (_leader ~= nil) then 
			UpdateReticle()
		end
	end
end

--[[
	Initialize initializes TGT_CenteredLeaderMarker
]]--
function TGT_CenteredLeaderMarker.Initialize()
    _logger = TGT_LOGGER

    SetControlActive()

    CALLBACK_MANAGER:RegisterCallback(TGT_ARROW_ACTIVE_CHANGED, SetControlActive)
    
    _logger:logTrace("TGT_CenteredLeaderMarker -> Initialized")
end