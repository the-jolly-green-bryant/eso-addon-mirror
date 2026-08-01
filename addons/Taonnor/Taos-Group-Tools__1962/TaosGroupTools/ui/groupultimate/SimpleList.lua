--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local TIMEOUT = PLAYERTIMEOUT

local _logger = nil
local _settingsHandler = TGT_SettingsHandler
local _playerHandler = TGT_PlayerHandler

local _name = "TGT-SimpleList"
local _control = TGT_SimpleListControl
local _controlTable = TGT_SimpleListControlContainer
local _isActive = false
local _isCreated = false
local _players = {}

--[[
	Table TGT_SimpleList
]]--
TGT_SimpleList = {}
TGT_SimpleList.__index = TGT_SimpleList

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	Updates list row
]]--
local function UpdateListRow(row, player)
    local localizedUltimateName = zo_strformat(SI_ABILITY_TOOLTIP_NAME, player.UltimateName)
    local playerName = player.PlayerName
    if (_settingsHandler.SavedVariables.AccountNames) then
        playerName = GetUnitDisplayName(player.PingTag)
    end

    if (_settingsHandler.SavedVariables.CombatActive[GROUP_ULTIMATE] and player.IsPlayerInCombat) then
        playerName = playerName .. "*"
    end

    local resourcesString = player.RelativeUltimate

    if (_settingsHandler.SavedVariables.IsGroupResourcesEnabled) then
        resourcesString = zo_strformat("<<1>>/<<2>>/<<3>>", player.RelativeUltimate, player.RelativeStamina, player.RelativeMagicka)
    end

    row:GetNamedChild("SenderNameValueLabel"):SetText(playerName)
	row:GetNamedChild("UltimateValueLabel"):SetText(localizedUltimateName)
	row:GetNamedChild("ReadyValueLabel"):SetText(resourcesString)

    if (player.IsPlayerTimedOut or player.IsPlayerOnline == false) then
		row:GetNamedChild("SenderNameValueLabel"):SetColor(0.3, 0.3, 0.3, 1)
		row:GetNamedChild("UltimateValueLabel"):SetColor(0.3, 0.3, 0.3, 1)
		row:GetNamedChild("ReadyValueLabel"):SetColor(0.3, 0.3, 0.3, 1)
	elseif (player.IsPlayerDead) then
        row:GetNamedChild("SenderNameValueLabel"):SetColor(1.0, 0.0, 0.0, 1)
		row:GetNamedChild("UltimateValueLabel"):SetColor(1.0, 0.0, 0.0, 1)
		row:GetNamedChild("ReadyValueLabel"):SetColor(1.0, 0.0, 0.0, 1)
    elseif (player.RelativeUltimate == 100) then
		row:GetNamedChild("SenderNameValueLabel"):SetColor(0.0, 1.0, 0.0, 1)
		row:GetNamedChild("UltimateValueLabel"):SetColor(0.0, 1.0, 0.0, 1)
		row:GetNamedChild("ReadyValueLabel"):SetColor(0.0, 1.0, 0.0, 1)
	else
		row:GetNamedChild("SenderNameValueLabel"):SetColor(1.0, 1.0, 1.0, 1)
		row:GetNamedChild("UltimateValueLabel"):SetColor(1.0, 1.0, 1.0, 1)
		row:GetNamedChild("ReadyValueLabel"):SetColor(1.0, 1.0, 1.0, 1)
	end

    if (row:IsHidden()) then
		row:SetHidden(false)
	end
end

--[[
	Compare
]]--
local function Compare(playerLeft, playerRight)
    if (playerLeft.RelativeUltimate == playerRight.RelativeUltimate) then
        return playerLeft.PlayerPosition < playerRight.PlayerPosition
    else
        return playerLeft.RelativeUltimate > playerRight.RelativeUltimate
    end
end

--[[
	Sets visibility of labels
]]--
local function RefreshList()
    local functionTimestamp = GetGameTimeMilliseconds()

    local players = {}
    local nextFreeRow = 1
    
    for i,player in pairs(_playerHandler.GetRemoteGroupPlayers()) do
        if (player.UltimateGroup ~= nil) then
            players[nextFreeRow] = player
            nextFreeRow = nextFreeRow + 1
        end
    end
    
    if (_settingsHandler.SavedVariables.IsSortingActive) then
	    table.sort(players, Compare)
    end

    local lastRow = nil

    for i=1, GROUP_SIZE_MAX, 1 do
        local row = _controlTable:GetNamedChild("Row" .. i)
        local listPlayer = players[i]

        if (listPlayer ~= nil) then
		    row:ClearAnchors()

		    if i == 1 then
                row:SetAnchor(TOPLEFT, _controlTable, TOPLEFT, 0, 0)
                row:SetAnchor(TOPRIGHT, _controlTable, TOPRIGHT, 0, 0)
            else
                row:SetAnchor(TOPLEFT, lastRow, BOTTOMLEFT, 0, 0)
                row:SetAnchor(TOPRIGHT, lastRow, BOTTOMRIGHT, 0, 0)
            end
		
		    lastRow = row

            listPlayer.UltimateSimpleListRow = row
            UpdateListRow(row, listPlayer)
        else
		    row:ClearAnchors()
            row:SetHidden(true)
        end
    end
	
    _logger:logTrace("TGT_SimpleList -> RefreshList", GetGameTimeMilliseconds() - functionTimestamp)
end

--[[
	Updates players
]]--
local function UpdatePlayer(player)
	if (player) then
        if (player.UltimateSimpleListRow ~= nil) then
            UpdateListRow(player.UltimateSimpleListRow, player)
        end
    end
end

--[[
	Clears player
]]--
local function ClearPlayer(player)
	if (player) then
        player.UltimateSimpleListRow = nil
    end
end

--[[
	SetControlMovable sets the Movable and MouseEnabled flag in UI elements
]]--
local function SetControlMovable(isMovable)
    local isMovable = _settingsHandler.SavedVariables.Movable

    _control:GetNamedChild("MovableControl"):SetHidden(isMovable == false)
    _control:SetMovable(isMovable)
	_control:SetMouseEnabled(isMovable)
end

--[[
	RestorePosition sets TGT_SimpleList on settings position
]]--
local function RestorePosition()
    local posX = _settingsHandler.SavedVariables.Position[GROUP_ULTIMATE].PosX
    local posY = _settingsHandler.SavedVariables.Position[GROUP_ULTIMATE].PosY

	_control:ClearAnchors()
	_control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, posX, posY)
end

--[[
	SetControlHidden sets hidden on control
]]--
local function SetControlHidden()
    -- Get isActive from settings
    if (_settingsHandler.IsSimpleListVisible() and _isCreated) then
        if (GetIsUnitGrouped() and GetGroupSize() >= _settingsHandler.SavedVariables.VisibleOffset[GROUP_ULTIMATE]) then
            _control:SetHidden(CurrentHudHiddenState())
        else
            _control:SetHidden(true)
        end
    else
        _control:SetHidden(true)
    end
end

--[[
	SetGroupResources shows/hide the GroupResources UI elements
]]--
local function SetGroupResources()
    if (_settingsHandler.SavedVariables.IsGroupResourcesEnabled) then
        _control:GetNamedChild("ReadyHeaderLabel"):SetText("Ult/Stam/Mag")
    else
        _control:GetNamedChild("ReadyHeaderLabel"):SetText("Ultimate")
    end
end

--[[
	CreateSimpleListRows creates simple list rows
]]--
local function CreateSimpleListRows()
	for i=1, GROUP_SIZE_MAX, 1 do
		local row = CreateControlFromVirtual("$(parent)Row", _controlTable, "GroupUltimateSimpleListRow", i)

		row:SetHidden(true) -- initial not visible
	end
end

--[[
	SetControlActive sets hidden on control
]]--
local function SetControlActive()
    SetControlHidden()

    -- Get isActive from settings
    local isActive = _settingsHandler.IsSimpleListVisible()

    if (_isActive ~= isActive) then
        _isActive = isActive

        if (isActive) then
            -- Workaround: To avoid "Too many anchors processed" error; Thank you ZOS for stealing hours of my life!
            if (_isCreated == false) then
                _isCreated = true
                CreateSimpleListRows()
            end

            SetControlMovable()
            RestorePosition()
            SetGroupResources()
            RefreshList()
            
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_REFRESH, RefreshList)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_REMOTE_CHANGED, UpdatePlayer)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_CLEAR, ClearPlayer)
            CALLBACK_MANAGER:RegisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:RegisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TGT_VISIBLE_OFFSET_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_RESOURCES_ENABLED_CHANGED, SetGroupResources)
        else
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_REFRESH, RefreshList)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_REMOTE_CHANGED, UpdatePlayer)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_CLEAR, ClearPlayer)
            CALLBACK_MANAGER:UnregisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:UnregisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TGT_VISIBLE_OFFSET_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TGT_GROUP_RESOURCES_ENABLED_CHANGED, SetGroupResources)
        end
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	OnSimpleListMoveStop saves current TGT_SimpleList position to settings
]]--
function TGT_SimpleList.OnSimpleListMoveStop()
	local left = _control:GetLeft()
	local top = _control:GetTop()
	
    _settingsHandler.SavedVariables.Position[GROUP_ULTIMATE].PosX = left
    _settingsHandler.SavedVariables.Position[GROUP_ULTIMATE].PosY = top
end

--[[
	Initialize initializes TGT_SimpleList
]]--
function TGT_SimpleList.Initialize()
    _logger = TGT_LOGGER

    CALLBACK_MANAGER:RegisterCallback(TGT_STYLE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_SENDING_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_IS_ZONE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_ACTIVATED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_ULTIMATE_ENABLED_CHANGED, SetControlActive)

    _logger:logTrace("TGT_SimpleList -> Initialized")
end