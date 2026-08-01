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

local _name = "TGT-SimpleDpsHpsList"
local _controlDps = TGT_SimpleDpsListControl
local _controlDpsTable = TGT_SimpleDpsListControlContainer
local _controlHps = TGT_SimpleHpsListControl
local _controlHpsTable = TGT_SimpleHpsListControlContainer
local _isActive = false
local _isCreated = false

--[[
	Table TGT_SimpleDpsHpsList
]]--
TGT_SimpleDpsHpsList = {}
TGT_SimpleDpsHpsList.__index = TGT_SimpleDpsHpsList

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	Updates list row dps
]]--
local function UpdateListRowDps(row, player)
    local playerName = player.PlayerName
    if (_settingsHandler.SavedVariables.AccountNames) then
        playerName = GetUnitDisplayName(player.PingTag)
    end

    row:GetNamedChild("SenderNameValueLabel"):SetText(playerName)
	row:GetNamedChild("DpsValueLabel"):SetText(zo_strformat("<<1>> (<<2>>%)", player.DamageReceived, player.DamageReceivedRelative))
	
    if (player.IsPlayerTimedOut or player.IsPlayerOnline == false) then
		row:GetNamedChild("SenderNameValueLabel"):SetColor(0.3, 0.3, 0.3, 1)
		row:GetNamedChild("DpsValueLabel"):SetColor(0.3, 0.3, 0.3, 1)
	elseif (player.IsPlayerDead) then
        row:GetNamedChild("SenderNameValueLabel"):SetColor(1.0, 0.0, 0.0, 1)
		row:GetNamedChild("DpsValueLabel"):SetColor(1.0, 0.0, 0.0, 1)
	else
		row:GetNamedChild("SenderNameValueLabel"):SetColor(1.0, 1.0, 1.0, 1)
		row:GetNamedChild("DpsValueLabel"):SetColor(1.0, 1.0, 1.0, 1)
	end

    if (row:IsHidden()) then
		row:SetHidden(false)
	end
end

--[[
	Updates list row
]]--
local function UpdateListRowHps(row, player)
    local playerName = player.PlayerName
    if (_settingsHandler.SavedVariables.AccountNames) then
        playerName = GetUnitDisplayName(player.PingTag)
    end

    row:GetNamedChild("SenderNameValueLabel"):SetText(playerName)
	row:GetNamedChild("HpsValueLabel"):SetText(zo_strformat("<<1>> (<<2>>%)", player.HealingReceived, player.HealingReceivedRelative))
	
    if (player.IsPlayerTimedOut or player.IsPlayerOnline == false) then
		row:GetNamedChild("SenderNameValueLabel"):SetColor(0.3, 0.3, 0.3, 1)
		row:GetNamedChild("HpsValueLabel"):SetColor(0.3, 0.3, 0.3, 1)
	elseif (player.IsPlayerDead) then
        row:GetNamedChild("SenderNameValueLabel"):SetColor(1.0, 0.0, 0.0, 1)
		row:GetNamedChild("HpsValueLabel"):SetColor(1.0, 0.0, 0.0, 1)
	else
		row:GetNamedChild("SenderNameValueLabel"):SetColor(1.0, 1.0, 1.0, 1)
		row:GetNamedChild("HpsValueLabel"):SetColor(1.0, 1.0, 1.0, 1)
	end

    if (row:IsHidden()) then
		row:SetHidden(false)
	end
end

--[[
	CompareDamage
]]--
local function CompareDamage(playerLeft, playerRight)
    if (playerLeft ~= nil and playerRight ~= nil) then
        if (playerLeft.DamageReceived == playerRight.DamageReceived) then
			return playerLeft.PlayerPosition < playerRight.PlayerPosition
		else
			return playerLeft.DamageReceived > playerRight.DamageReceived
		end
    else
        return playerLeft ~= nil
    end
end

--[[
	CompareHeal
]]--
local function CompareHeal(playerLeft, playerRight)
    if (playerLeft ~= nil and playerRight ~= nil) then
        if (playerLeft.HealingReceived == playerRight.HealingReceived) then
			return playerLeft.PlayerPosition < playerRight.PlayerPosition
		else
			return playerLeft.HealingReceived > playerRight.HealingReceived
		end
    else
        return playerLeft ~= nil
    end
end

--[[
	Sets visibility of labels
]]--
local function RefreshList()
    local functionTimestamp = GetGameTimeMilliseconds()

    local playersDamage = {}
    local playersHeal = {}
    local nextFreeRow = 1

    for i,player in pairs(_playerHandler.GetRemoteGroupPlayers()) do
        playersDamage[nextFreeRow] = player
        playersHeal[nextFreeRow] = player

        nextFreeRow = nextFreeRow + 1
    end
    
    table.sort(playersDamage, CompareDamage)
	table.sort(playersHeal, CompareHeal)
    
	local lastRow = nil

	-- Dmg
    for i=1, GROUP_SIZE_MAX, 1 do
        local row = _controlDpsTable:GetNamedChild("Row" .. i)
        local listPlayer = playersDamage[i]

        if (listPlayer ~= nil) then
		    row:ClearAnchors()

		    if i == 1 then
                row:SetAnchor(TOPLEFT, _controlDpsTable, TOPLEFT, 0, 0)
                row:SetAnchor(TOPRIGHT, _controlDpsTable, TOPRIGHT, 0, 0)
            else
                row:SetAnchor(TOPLEFT, lastRow, BOTTOMLEFT, 0, 0)
                row:SetAnchor(TOPRIGHT, lastRow, BOTTOMRIGHT, 0, 0)
            end
		
		    lastRow = row

            UpdateListRowDps(row, listPlayer)
        else
		    row:ClearAnchors()
            row:SetHidden(true)
        end
    end
	
    lastRow = nil

	-- Heal
    for i=1, GROUP_SIZE_MAX, 1 do
        local row = _controlHpsTable:GetNamedChild("Row" .. i)
        local listPlayer = playersHeal[i]

        if (listPlayer ~= nil) then
            row:ClearAnchors()
		
		    if i == 1 then
                row:SetAnchor(TOPLEFT, _controlHpsTable, TOPLEFT, 0, 0)
                row:SetAnchor(TOPRIGHT, _controlHpsTable, TOPRIGHT, 0, 0)
            else
                row:SetAnchor(TOPLEFT, lastRow, BOTTOMLEFT, 0, 0)
                row:SetAnchor(TOPRIGHT, lastRow, BOTTOMRIGHT, 0, 0)
            end
		
		    lastRow = row

            UpdateListRowHps(row, listPlayer)
        else
            row:ClearAnchors()
            row:SetHidden(true)
        end
    end

    _logger:logTrace("TGT_SimpleDpsHpsList -> RefreshList", GetGameTimeMilliseconds() - functionTimestamp)
end

--[[
	SetControlMovable sets the Movable and MouseEnabled flag in UI elements
]]--
local function SetControlMovable()
    local isMovable = _settingsHandler.SavedVariables.Movable

    _controlDps:GetNamedChild("MovableControl"):SetHidden(isMovable == false)

    _controlDps:SetMovable(isMovable)
	_controlDps:SetMouseEnabled(isMovable)
	
	_controlHps:GetNamedChild("MovableControl"):SetHidden(isMovable == false)

    _controlHps:SetMovable(isMovable)
	_controlHps:SetMouseEnabled(isMovable)
end

--[[
	RestorePosition sets TGT_SimpleDpsHpsList on settings position
]]--
local function RestorePosition()
    local dpsPposX = _settingsHandler.SavedVariables.Position[GROUP_STATS].DpsList.PosX
    local dpsPposY = _settingsHandler.SavedVariables.Position[GROUP_STATS].DpsList.PosY

	_controlDps:ClearAnchors()
	_controlDps:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, dpsPposX, dpsPposY)
	
    local hpsPposX = _settingsHandler.SavedVariables.Position[GROUP_STATS].HpsList.PosX
    local hpsPposY = _settingsHandler.SavedVariables.Position[GROUP_STATS].HpsList.PosY

	_controlHps:ClearAnchors()
	_controlHps:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, hpsPposX, hpsPposY)
end

--[[
	SetControlHidden sets hidden on control
]]--
local function SetControlHidden()
    -- Get isActive from settings
    if (_settingsHandler.IsSimpleDpsHpsListVisible() and _isCreated) then
        if (GetIsUnitGrouped() and GetGroupSize() >= _settingsHandler.SavedVariables.VisibleOffset[GROUP_STATS]) then
			local dpsVisible = (_settingsHandler.SavedVariables.DpsHpsVisibleOption == 1 or _settingsHandler.SavedVariables.DpsHpsVisibleOption == 2)
			local hpsVisible = (_settingsHandler.SavedVariables.DpsHpsVisibleOption == 1 or _settingsHandler.SavedVariables.DpsHpsVisibleOption == 3)
			
			if (dpsVisible) then
				_controlDps:SetHidden(CurrentHudHiddenState())
			else
				_controlDps:SetHidden(true)
			end
			
			if (hpsVisible) then
				_controlHps:SetHidden(CurrentHudHiddenState())
			else
				_controlHps:SetHidden(true)
			end
        else
            _controlDps:SetHidden(true)
			_controlHps:SetHidden(true)
        end
    else
        _controlDps:SetHidden(true)
		_controlHps:SetHidden(true)
    end
end

--[[
	CreateSimpleListRows creates simple list rows
]]--
local function CreateSimpleListRows()
    -- Damage
	for i=1, GROUP_SIZE_MAX, 1 do
		local row = CreateControlFromVirtual("$(parent)Row", _controlDpsTable, "GroupDpsSimpleListRow", i)

		row:SetHidden(true) -- initial not visible
	end
	
	-- Heal
	for i=1, GROUP_SIZE_MAX, 1 do
		local row = CreateControlFromVirtual("$(parent)Row", _controlHpsTable, "GroupHpsSimpleListRow", i)

		row:SetHidden(true) -- initial not visible
	end
end

--[[
	SetControlActive sets hidden on control
]]--
local function SetControlActive()
    SetControlHidden()

    -- Get isActive from settings
    local isActive = _settingsHandler.IsSimpleDpsHpsListVisible()

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
            RefreshList()

            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_REFRESH, RefreshList)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_REMOTE_CHANGED, UpdatePlayer)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_CLEAR, ClearPlayer)
            CALLBACK_MANAGER:RegisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_DPSHPS_PART_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TGT_VISIBLE_OFFSET_CHANGED, SetControlHidden)
        else
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_REFRESH, RefreshList)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_REMOTE_CHANGED, UpdatePlayer)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_CLEAR, ClearPlayer)
            CALLBACK_MANAGER:UnregisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:UnregisterCallback(TGT_GROUP_DPSHPS_PART_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TGT_VISIBLE_OFFSET_CHANGED, SetControlHidden)
        end
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	OnSimpleListMoveStop saves current TGT_SimpleDpsHpsList position to settings
]]--
function TGT_SimpleDpsHpsList.OnSimpleListMoveStop()
    _settingsHandler.SavedVariables.Position[GROUP_STATS].DpsList.PosX = _controlDps:GetLeft()
    _settingsHandler.SavedVariables.Position[GROUP_STATS].DpsList.PosY = _controlDps:GetTop()
    
    _settingsHandler.SavedVariables.Position[GROUP_STATS].HpsList.PosX = _controlHps:GetLeft()
    _settingsHandler.SavedVariables.Position[GROUP_STATS].HpsList.PosY = _controlHps:GetTop()
end

--[[
	Initialize initializes TGT_SimpleDpsHpsList
]]--
function TGT_SimpleDpsHpsList.Initialize()
    _logger = TGT_LOGGER

    CALLBACK_MANAGER:RegisterCallback(TGT_STYLE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_SENDING_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_IS_ZONE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_ACTIVATED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_DPSHPS_ENABLED_CHANGED, SetControlActive)
    
    _logger:logTrace("TGT_SimpleDpsHpsList -> Initialized")
end