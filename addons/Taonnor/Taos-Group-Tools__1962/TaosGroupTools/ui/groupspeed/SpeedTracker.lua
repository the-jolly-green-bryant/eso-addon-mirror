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
local _playerHandler = TGT_PlayerHandler

local UPDATE = 0.1 -- s
local SPEEDBUFF = SPEEDBUFF_ICON_ID

local _isActive = false
local _isCreated = false
local _control = TGT_SpeedTrackerControl

--[[
	Table TGT_SpeedTracker
]]--
TGT_SpeedTracker = {}
TGT_SpeedTracker.__index = TGT_SpeedTracker

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	ShowTrackers
]]--
local function ShowTrackers()
    local trackerContainer = _control:GetNamedChild("Container")
    local lastTracker = nil

    for i, tracker in ipairs(_control.Trackers) do
        -- Set hidden state
        if (tracker.Player) then
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
	UpdateTracker
]]--
local function UpdateTracker(player, tracker)
    local startTime = player.Buffs[SPEEDBUFF].startTime
    local finishTime = player.Buffs[SPEEDBUFF].finishTime

    tracker.Start = startTime
    tracker.Finish = finishTime
    tracker.TimeRemaining = finishTime - startTime
end

--[[
	UpdateSpeed
]]--
local function UpdateSpeed(player)
    local tracker = GetPlayerTracker(player)

    if (tracker) then
        tracker.Player = player

        UpdateTracker(player, tracker)
        ShowTrackers()
    else
        _logger:logError("TGT_SpeedTracker -> UpdateSpeed; No tracker")
    end
end

--[[
	UpdatePlayerBuffs
]]--
local function UpdatePlayerBuffs(player, abilityId)
	if (player and abilityId == SPEEDBUFF) then
        UpdateSpeed(player)
    end
end

--[[
	UpdateSpeedFrameHeader sets deto frame header hidden
]]--
local function UpdateSpeedFrameHeader()
    local isHidden = _settingsHandler.SavedVariables.IsGroupSpeedHeaderVisible == false
    _control:GetNamedChild("HeaderLabel"):SetHidden(isHidden)
end

--[[
	SetControlColor sets control color
]]--
local function SetControlColors(part)
    if (part == GROUP_SPEED) then
        local controlColor = _settingsHandler.SavedVariables.ModuleColors[part].GroupSpeedColor
        local labelColor = GetAdjustedLabelColor(controlColor)
	    
        for i, tracker in ipairs(_control.Trackers) do
            tracker.StatusBar:SetColor(controlColor.R, controlColor.G, controlColor.B, controlColor.A)
            tracker.TimeLabel:SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
        end
    end
end

--[[
	ResizeControl resizes container control
]]--
local function ResizeControl()
    local size = _settingsHandler.SavedVariables.GroupSpeedSize
    local height = GROUP_SIZE_MAX * size.Height + _control:GetNamedChild("HeaderLabel"):GetHeight()

    _control:SetDimensions(size.Width, height)
end

--[[
	ResizeSpeedBars resizes deto bars
]]--
local function ResizeSpeedBars()
    local size = _settingsHandler.SavedVariables.GroupSpeedSize

    for i, tracker in ipairs(_control.Trackers) do
        tracker:SetDimensions(size.Width, size.Height)
        tracker.TimeLabel:SetDimensions(size.Width - 10, size.Height - 2)
    end

    ShowTrackers() -- Resets anchors
    ResizeControl()
end

--[[
	RestorePosition sets settings position
]]--
local function RestorePosition()
    local posX = _settingsHandler.SavedVariables.Position[GROUP_SPEED].PosX
    local posY = _settingsHandler.SavedVariables.Position[GROUP_SPEED].PosY

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
    if (_settingsHandler.SavedVariables.IsGroupSpeedEnabled and _isCreated) then
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

    for i=1, GROUP_SIZE_MAX, 1 do
        local tracker = CreateControlFromVirtual("$(parent)SpeedTracker", trackerContainer, "TimedBuffTrackerControl", i)
        tracker.StatusBar = tracker:GetNamedChild("StatusBar")
        tracker.TimeLabel = tracker:GetNamedChild("TimeLabel")
        tracker.Start = 0
        tracker.Finish = 0
        tracker.NextUpdate = 0
        tracker.TimeRemaining = -1

        -- Update handler for castbar
	    local function OnUpdate(self, updateTime)
		    if (updateTime >= self.NextUpdate and self.Player) then
			    self.TimeRemaining = self.Finish - updateTime

                local playerName = self.Player.PlayerName
                if (_settingsHandler.SavedVariables.AccountNames) then
                    playerName = GetUnitDisplayName(self.Player.PingTag)
                end

			    if (self.TimeRemaining <= 0) then
                    self.Start = 0
                    self.Finish = 0
                    self.TimeRemaining = -1
                    self.StatusBar:SetValue(0)

                    self.TimeLabel:SetText(zo_strformat("0 - <<1>>", playerName))
			    else
                    local relativeTime = 1 - (updateTime - self.Start) / (self.Finish - self.Start)
                    ZO_StatusBar_SmoothTransition(self.StatusBar, relativeTime, 1, false)
                    local timeString = ZO_FormatTime(self.TimeRemaining, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL_SHOW_TENTHS_SECS, TIME_FORMAT_PRECISION_TENTHS, TIME_FORMAT_DIRECTION_DESCENDING)

				    self.TimeLabel:SetText(zo_strformat("<<1>> - <<2>>", timeString, playerName))
			    end

			    nextUpdate = updateTime + UPDATE
            end
	    end

	    tracker:SetHandler('OnUpdate', OnUpdate)

        tracker:ClearAnchors()
        tracker:SetHidden(true)

        _control.Trackers[i] = tracker
    end
end

--[[
	SetupPlayers sets players in trackers
]]--
local function SetupPlayers()
    -- Clear trackers to refreshes them if player out of group
    for i, tracker in ipairs(_control.Trackers) do
        tracker.Player = nil
        tracker:ClearAnchors()
        tracker:SetHidden(true)
    end

    local players = _playerHandler.GetGroupPlayers()

    for i,player in pairs(players) do
        local tracker = GetPlayerTracker(player)

        if (tracker) then
            tracker.Player = player

            if (player.Buffs[SPEEDBUFF]) then
                UpdateTracker(player, tracker)
            end
        else
            _logger:logError("TGT_SpeedTracker -> UpdateSpeed; No tracker")
        end
    end

    ShowTrackers()
end

--[[
	SetControlActive sets hidden on control
]]--
local function SetControlActive()
    SetControlHidden()

    -- Get isActive from settings
    local isActive = _settingsHandler.SavedVariables.IsGroupSpeedEnabled

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
            UpdateSpeedFrameHeader()
            SetControlColors(GROUP_SPEED)
            ResizeSpeedBars()
            SetupPlayers()

            CALLBACK_MANAGER:RegisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_BUFFS_CHANGED, UpdatePlayerBuffs)
            CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_SPEED_HEADER_CHANGED, UpdateSpeedFrameHeader)
            CALLBACK_MANAGER:RegisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
            CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_SPEED_SIZE_CHANGED, ResizeSpeedBars)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_CLEAR, SetupPlayers)
            CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetupPlayers)
            CALLBACK_MANAGER:RegisterCallback(TAO_GROUP_CHANGED, SetupPlayers)
        else
            CALLBACK_MANAGER:UnregisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_BUFFS_CHANGED, UpdatePlayerBuffs)
            CALLBACK_MANAGER:UnregisterCallback(TGT_GROUP_SPEED_HEADER_CHANGED, UpdateSpeedFrameHeader)
            CALLBACK_MANAGER:UnregisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
            CALLBACK_MANAGER:UnregisterCallback(TGT_GROUP_SPEED_SIZE_CHANGED, ResizeSpeedBars)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_CLEAR, SetupPlayers)
            CALLBACK_MANAGER:UnregisterCallback(TAO_UNIT_GROUPED_CHANGED, SetupPlayers)
            CALLBACK_MANAGER:UnregisterCallback(TAO_GROUP_CHANGED, SetupPlayers)
        end
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	TGT_SpeedTracker_OnMoveStop saves position
]]--
function TGT_SpeedTracker_OnMoveStop(control)
    _settingsHandler.SavedVariables.Position[GROUP_SPEED].PosX = control:GetLeft()
    _settingsHandler.SavedVariables.Position[GROUP_SPEED].PosY = control:GetTop()
end

--[[
	Initialize initializes TGT_SpeedTracker
]]--
function TGT_SpeedTracker.Initialize()
    _logger = TGT_LOGGER

    CALLBACK_MANAGER:RegisterCallback(TGT_IS_ZONE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_ACTIVATED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_SPEED_ENABLED_CHANGED, SetControlActive)
    
    _logger:logTrace("TGT_SpeedTracker -> Initialized")
end