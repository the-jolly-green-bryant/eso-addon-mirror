--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local EARTHGORE = EARTHGORE_ICON_ID

local _logger = nil
local _settingsHandler = TGT_SettingsHandler

local _isActive = false
local _isCreated = false
local _control = TGT_EarthgoreTrackerControl

--[[
	Table TGT_EarthgoreTracker
]]--
TGT_EarthgoreTracker = {}
TGT_EarthgoreTracker.__index = TGT_EarthgoreTracker

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	SortTrackers
]]--
local function SortTrackers()
    local trackerContainer = _control:GetNamedChild("Container")
    local lastTracker = nil

    for i, tracker in ipairs(_control.Trackers) do
        -- Set hidden state
        if (tracker.Player and tracker.EarthgoreTimeStamp >= 0) then
            -- Set anchor
            tracker:ClearAnchors()
        
            if (i == 1) then
                tracker:SetAnchor(TOPLEFT, trackerContainer, TOPLEFT, 0, 3)
            else
		        tracker:SetAnchor(TOPLEFT, lastTracker, BOTTOMLEFT, 0, 3)
	        end

            lastTracker = tracker
            tracker:SetHidden(false)
        else
            tracker:ClearAnchors()
            tracker:SetHidden(true)
        end
    end

    return lastTracker
end

--[[
	GetPlayerTracker
]]--
local function GetPlayerTracker(player)
    -- search player
    for i, tracker in ipairs(_control.Trackers) do
        if (tracker.Player ~= nil and tracker.Player.PlayerName == player.PlayerName) then
            return tracker
        end
    end

    -- search free
    for i, tracker in ipairs(_control.Trackers) do
        if (tracker.Player == nil) then
            return tracker
        end
    end

    return nil
end

--[[
	SetupTracker
]]--
local function SetupTracker(player, tracker)
    tracker.EarthgoreTimeStamp = GetGameTimeMilliseconds()
    tracker.Player = player

    local playerName = player.PlayerName
    if (_settingsHandler.SavedVariables.AccountNames) then
        playerName = GetUnitDisplayName(player.PingTag)
    end

    tracker.TimeLabel:SetText(zo_strformat("<<1>>", playerName))
end

--[[
	UpdatePlayerEarthgore
]]--
local function UpdatePlayerEarthgore(player)
    if (player) then
        local tracker = GetPlayerTracker(player)

        if (tracker) then
            if (player.Buffs[EARTHGORE] ~= nil and player.Buffs[EARTHGORE].isActive) then
                SetupTracker(player, tracker)
            else
                tracker:SetHidden(true)
                tracker.EarthgoreTimeStamp = -1
                tracker.Player = nil
            end

            SortTrackers()
        else
            _logger:logError("TGT_EarthgoreTracker -> UpdatePlayerPurgable; No tracker")
        end
    end
end

--[[
	UpdateEarthgoreFrameHeader sets Earthgore frame header hidden
]]--
local function UpdateEarthgoreFrameHeader()
    local isHidden = _settingsHandler.SavedVariables.IsGroupEarthgoreHeaderVisible == false
    _control:GetNamedChild("HeaderLabel"):SetHidden(isHidden)
end

--[[
	SetControlColor sets control color
]]--
local function SetControlColors(part)
    if (part == GROUP_EARTHGORE) then
        local controlColor = _settingsHandler.SavedVariables.ModuleColors[part].GroupEarthgoreColor
        local labelColor = GetAdjustedLabelColor(controlColor)
	    
        for i, tracker in ipairs(_control.Trackers) do
            tracker.Background:SetAlpha(1)
            tracker.Background:SetCenterColor(controlColor.R, controlColor.G, controlColor.B, controlColor.A)
            tracker.TimeLabel:SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
        end
    end
end

--[[
	ResizeControl resizes container control
]]--
local function ResizeControl()
    local size = _settingsHandler.SavedVariables.GroupEarthgoreSize
    local height = GROUP_SIZE_MAX * size.Height + _control:GetNamedChild("HeaderLabel"):GetHeight()

    _control:SetDimensions(size.Width, height)
end

--[[
	ResizeEarthgoreBars resizes Earthgore bars
]]--
local function ResizeEarthgoreBars()
    local size = _settingsHandler.SavedVariables.GroupEarthgoreSize

    for i, tracker in ipairs(_control.Trackers) do
        tracker:SetDimensions(size.Width, size.Height)
        tracker.TimeLabel:SetDimensions(size.Width - 10, size.Height - 2)
    end

    SortTrackers() -- Resets anchors
    ResizeControl()
end

--[[
	RestorePosition sets settings position
]]--
local function RestorePosition()
    local posX = _settingsHandler.SavedVariables.Position[GROUP_EARTHGORE].PosX
    local posY = _settingsHandler.SavedVariables.Position[GROUP_EARTHGORE].PosY

    _control:ClearAnchors()
    _control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, posX, posY)
end

--[[
	SetControlMovable sets the Movable and MouseEnabled flag in UI elements
]]--
local function SetControlMovable()
    local isMovable = _settingsHandler.SavedVariables.Movable

    _control:GetNamedChild("MovableControl"):SetHidden(isMovable == false)

    _control:SetMovable(isMovable)
	_control:SetMouseEnabled(isMovable)
end

--[[
	SetControlHidden sets hidden on control
]]--
local function SetControlHidden()
    -- Get isActive from settings
    if (_settingsHandler.SavedVariables.IsGroupEarthgoreEnabled and _isCreated) then
        if (GetIsUnitGrouped()) then
			_control:SetHidden(CurrentHudHiddenState())
        else
            _control:SetHidden(true)
        end
    else
        _control:SetHidden(true)
    end
end

--[[
	CreateTrackers creates tracker sub controls
]]--
local function CreateTrackers()
    local trackerContainer = _control:GetNamedChild("Container")
    _control.Trackers = {}
    local lastTracker = nil

    for i=1, GROUP_SIZE_MAX, 1 do
        local tracker = CreateControlFromVirtual("$(parent)EarthgoreTracker", trackerContainer, "TimedBuffTrackerControl", i)
        tracker:GetNamedChild("StatusBar"):SetHidden(true)
        tracker.Background = tracker:GetNamedChild("Background")
        tracker.TimeLabel = tracker:GetNamedChild("TimeLabel")
        tracker.EarthgoreTimeStamp = -1

        tracker:ClearAnchors()
        tracker:SetHidden(true)

        lastTracker = tracker
        _control.Trackers[i] = tracker
    end
end

--[[
	SetControlActive sets hidden on control
]]--
local function SetControlActive()
    SetControlHidden()

    -- Get isActive from settings
    local isActive = _settingsHandler.SavedVariables.IsGroupEarthgoreEnabled

    if (_isActive ~= isActive) then
        _isActive = isActive

        if (isActive) then
            -- Workaround: To avoid "Too many anchors processed" error; Thank you ZOS for stealing hours of my life!
            if (_isCreated == false) then
                _isCreated = true
                CreateTrackers()
            end

            SetControlMovable()
            RestorePosition()
            UpdateEarthgoreFrameHeader()
            SetControlColors(GROUP_EARTHGORE)
            ResizeEarthgoreBars()
            
            CALLBACK_MANAGER:RegisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_REMOTE_CHANGED, UpdatePlayerEarthgore)
            CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_EARTHGORE_HEADER_CHANGED, UpdateEarthgoreFrameHeader)
            CALLBACK_MANAGER:RegisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
            CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_EARTHGORE_SIZE_CHANGED, ResizeEarthgoreBars)
        else
            CALLBACK_MANAGER:UnregisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_REMOTE_CHANGED, UpdatePlayerEarthgore)
            CALLBACK_MANAGER:UnregisterCallback(TGT_GROUP_EARTHGORE_HEADER_CHANGED, UpdateEarthgoreFrameHeader)
            CALLBACK_MANAGER:UnregisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
            CALLBACK_MANAGER:UnregisterCallback(TGT_GROUP_EARTHGORE_SIZE_CHANGED, ResizeEarthgoreBars)
        end
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	TGT_EarthgoreTracker_OnMoveStop saves position
]]--
function TGT_EarthgoreTracker_OnMoveStop(control)
    _settingsHandler.SavedVariables.Position[GROUP_EARTHGORE].PosX = control:GetLeft()
    _settingsHandler.SavedVariables.Position[GROUP_EARTHGORE].PosY = control:GetTop()
end

--[[
	Initialize initializes TGT_EarthgoreTracker
]]--
function TGT_EarthgoreTracker.Initialize()
    _logger = TGT_LOGGER

    CALLBACK_MANAGER:RegisterCallback(TGT_IS_ZONE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_ACTIVATED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_EARTHGORE_ENABLED_CHANGED, SetControlActive)
    
    _logger:logTrace("TGT_EarthgoreTracker -> Initialized")
end