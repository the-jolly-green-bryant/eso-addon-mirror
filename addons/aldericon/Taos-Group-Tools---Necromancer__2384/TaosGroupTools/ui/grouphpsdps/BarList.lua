--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local HALF_GROUP_SIZE = 12

local _logger = nil
local _settingsHandler = TGT_SettingsHandler
local _playerHandler = TGT_PlayerHandler

local _control = TGT_BarListListControl
local _controlLabelColor = nil
local _isActive = false
local _isCreated = false

--[[
	Table TGT_DpsHpsBarList
]]--
TGT_DpsHpsBarList = {}
TGT_DpsHpsBarList.__index = TGT_DpsHpsBarList

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

    row:GetNamedChild("ValueLabel"):SetText(zo_strformat("<<1>> - <<2>>", player.DamageReceived, playerName))
    ZO_StatusBar_SmoothTransition(row:GetNamedChild("StatusBar"), player.DamageReceivedRelative, 100, false)
	
    if (player.IsPlayerTimedOut or player.IsPlayerOnline == false) then
		row:GetNamedChild("ValueLabel"):SetColor(0.3, 0.3, 0.3, 1)
	elseif (player.IsPlayerDead) then
        row:GetNamedChild("ValueLabel"):SetColor(1.0, 0.0, 0.0, 1)
	else
        local color = _controlLabelColor
		row:GetNamedChild("ValueLabel"):SetColor(color.R, color.G, color.B, color.A)
	end

    local gloss = row:GetNamedChild("StatusBar"):GetNamedChild("Gloss")
    if (_settingsHandler.SavedVariables.ShowBarGloss) then
        if (gloss:IsHidden()) then
            gloss:SetHidden(false)
        end
    else
        if (gloss:IsHidden() == false) then
            gloss:SetHidden(true)
        end
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

    row:GetNamedChild("ValueLabel"):SetText(zo_strformat("<<1>> - <<2>>", player.HealingReceived, playerName))
    ZO_StatusBar_SmoothTransition(row:GetNamedChild("StatusBar"), player.HealingReceivedRelative, 100, false)
	
    if (player.IsPlayerTimedOut or player.IsPlayerOnline == false) then
		row:GetNamedChild("ValueLabel"):SetColor(0.3, 0.3, 0.3, 1)
	elseif (player.IsPlayerDead) then
        row:GetNamedChild("ValueLabel"):SetColor(1.0, 0.0, 0.0, 1)
	else
		row:GetNamedChild("ValueLabel"):SetColor(1.0, 1.0, 1.0, 1)
	end
    
    local gloss = row:GetNamedChild("StatusBar"):GetNamedChild("Gloss")
    if (_settingsHandler.SavedVariables.ShowBarGloss) then
        if (gloss:IsHidden()) then
            gloss:SetHidden(false)
        end
    else
        if (gloss:IsHidden() == false) then
            gloss:SetHidden(true)
        end
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
    for i=1, HALF_GROUP_SIZE, 1 do
        local row = _control.DamageTable:GetNamedChild("Row" .. i)
        local listPlayer = playersDamage[i]

        if (listPlayer ~= nil) then
		    row:ClearAnchors()

		    if i == 1 then
                row:SetAnchor(TOPLEFT, _control.DamageTable, TOPLEFT, 0, 0)
                row:SetAnchor(TOPRIGHT, _control.DamageTable, TOPRIGHT, 0, 0)
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
    for i=1, HALF_GROUP_SIZE, 1 do
        local row = _control.HealTable:GetNamedChild("Row" .. i)
        local listPlayer = playersHeal[i]

        if (listPlayer ~= nil) then
            row:ClearAnchors()
		
		    if i == 1 then
                row:SetAnchor(TOPLEFT, _control.HealTable, TOPLEFT, 0, 0)
                row:SetAnchor(TOPRIGHT, _control.HealTable, TOPRIGHT, 0, 0)
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

    _logger:logTrace("TGT_DpsHpsBarList -> RefreshList", GetGameTimeMilliseconds() - functionTimestamp)
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
	RestorePosition sets TGT_DpsHpsBarList on settings position
]]--
local function RestorePosition()
    local dpsPposX = _settingsHandler.SavedVariables.Position[GROUP_STATS].BarList.PosX
    local dpsPposY = _settingsHandler.SavedVariables.Position[GROUP_STATS].BarList.PosY

	_control:ClearAnchors()
	_control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, dpsPposX, dpsPposY)
end

--[[
	ToggleStyle
]]--
local function ToggleStyle(style)
    if (style == 1) then
        _control.DamageTable:SetDimensions(200, 240)
        _control:GetNamedChild("Header"):GetNamedChild("DamageLabel"):SetDimensions(200, 20)
        _control:GetNamedChild("Header"):GetNamedChild("DamageLabel"):SetHidden(false)
        _control.DamageTable:SetHidden(false)
        _control.HealTable:SetDimensions(200, 240)
        _control:GetNamedChild("Header"):GetNamedChild("HealLabel"):SetDimensions(200, 20)
        _control:GetNamedChild("Header"):GetNamedChild("HealLabel"):SetHidden(false)
        _control.HealTable:SetHidden(false)
    elseif (style == 2) then
        _control.DamageTable:SetDimensions(400, 240)
        _control:GetNamedChild("Header"):GetNamedChild("DamageLabel"):SetDimensions(400, 20)
        _control:GetNamedChild("Header"):GetNamedChild("DamageLabel"):SetHidden(false)
        _control.DamageTable:SetHidden(false)
        _control.HealTable:SetDimensions(0, 0)
        _control:GetNamedChild("Header"):GetNamedChild("HealLabel"):SetHidden(true)
        _control.HealTable:SetHidden(true)
    elseif (style == 3) then
        _control.DamageTable:SetDimensions(0,0)
        _control:GetNamedChild("Header"):GetNamedChild("DamageLabel"):SetHidden(true)
        _control.DamageTable:SetHidden(true)
        _control.HealTable:SetDimensions(400, 240)
        _control:GetNamedChild("Header"):GetNamedChild("HealLabel"):SetDimensions(400, 20)
        _control:GetNamedChild("Header"):GetNamedChild("HealLabel"):SetHidden(false)
        _control.HealTable:SetHidden(false)
    else
        -- Should not happen
        _logger:logError("TGT_DpsHpsBarList -> ToggleStyle; Wrong style", style)
    end
end

--[[
	SetControlHidden sets hidden on control
]]--
local function SetControlHidden()
    -- Get isActive from settings
    if (_settingsHandler.IsBarListVisible() and _isCreated) then
        if (GetIsUnitGrouped() and GetGroupSize() >= _settingsHandler.SavedVariables.VisibleOffset[GROUP_STATS]) then
            local isHidden = CurrentHudHiddenState()
			_control:SetHidden(isHidden)

            if (isHidden == false) then
                ToggleStyle(_settingsHandler.SavedVariables.DpsHpsVisibleOption)
            end
        else
            _control:SetHidden(true)
        end
    else
        _control:SetHidden(true)
    end
end

--[[
	SetControlColor sets control color
]]--
local function SetControlColors(part)
    if (part == GROUP_STATS) then
        local controlColor = _settingsHandler.SavedVariables.ModuleColors[part].GroupHpsDpsBarColor
        _controlLabelColor = GetAdjustedLabelColor(controlColor)
	    
        for i=1, HALF_GROUP_SIZE, 1 do
            local rowDmg = _control.DamageTable:GetNamedChild("Row" .. i)
            local rowHeal = _control.HealTable:GetNamedChild("Row" .. i)

            rowDmg:GetNamedChild("StatusBar"):SetColor(controlColor.R, controlColor.G, controlColor.B, controlColor.A)
            rowDmg:GetNamedChild("StatusBar"):SetAlpha(controlColor.A)

            rowHeal:GetNamedChild("StatusBar"):SetColor(controlColor.R, controlColor.G, controlColor.B, controlColor.A)
            rowHeal:GetNamedChild("StatusBar"):SetAlpha(controlColor.A)
        end
    end
end

--[[
	CreateBarListRows creates list rows
]]--
local function CreateBarListRows()
    local dmgTable = _control:GetNamedChild("DmgContainer")
    local healTable = _control:GetNamedChild("HealContainer")
    
    _control.DamageTable = dmgTable
    _control.HealTable = healTable

    -- Damage
	for i=1, HALF_GROUP_SIZE, 1 do
		local row = CreateControlFromVirtual("$(parent)Row", dmgTable, "BarListRow", i)

		row:SetHidden(true) -- initial not visible
	end
	
	-- Heal
	for i=1, HALF_GROUP_SIZE, 1 do
		local row = CreateControlFromVirtual("$(parent)Row", healTable, "BarListRow", i)

		row:SetHidden(true) -- initial not visible
	end
end

--[[
	SetControlActive sets hidden on control
]]--
local function SetControlActive()
    SetControlHidden()

    -- Get isActive from settings
    local isActive = _settingsHandler.IsBarListVisible()

    if (_isActive ~= isActive) then
        _isActive = isActive

        if (isActive) then
            -- Workaround: To avoid "Too many anchors processed" error; Thank you ZOS for stealing hours of my life!
            if (_isCreated == false) then
                _isCreated = true
                CreateBarListRows()
            end

            SetControlMovable()
            RestorePosition()
            SetControlColors(GROUP_STATS)
            RefreshList()

            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_REFRESH, RefreshList)
            CALLBACK_MANAGER:RegisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_DPSHPS_PART_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TGT_VISIBLE_OFFSET_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
        else		
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_REFRESH, RefreshList)
            CALLBACK_MANAGER:UnregisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:UnregisterCallback(TGT_GROUP_DPSHPS_PART_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TGT_VISIBLE_OFFSET_CHANGED, SetControlHidden)
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
	TGT_DpsHpsBarList_OnMoveStop saves position
]]--
function TGT_DpsHpsBarList_OnMoveStop(control)
    _settingsHandler.SavedVariables.Position[GROUP_STATS].BarList.PosX = control:GetLeft()
    _settingsHandler.SavedVariables.Position[GROUP_STATS].BarList.PosY = control:GetTop()
end

--[[
	TGT_DpsHpsBarList_ButtonClicked toggles sub style
]]--
function TGT_DpsHpsBarList_ButtonClicked(button, index)
    _settingsHandler.SetDpsHpsVisibleOptionSettings(index)
end

--[[
	Initialize initializes TGT_DpsHpsBarList
]]--
function TGT_DpsHpsBarList.Initialize()
    _logger = TGT_LOGGER

    CALLBACK_MANAGER:RegisterCallback(TGT_STYLE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_SENDING_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_IS_ZONE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_ACTIVATED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_DPSHPS_ENABLED_CHANGED, SetControlActive)
    
    _logger:logTrace("TGT_DpsHpsBarList -> Initialized")
end