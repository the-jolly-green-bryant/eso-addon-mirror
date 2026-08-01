--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local SWIMLANES = 12
local ROWS = 6
local TIMEOUT = PLAYERTIMEOUT

local _logger = nil
local _settingsHandler = TGT_SettingsHandler
local _playerHandler = TGT_PlayerHandler
local _ultimateGroupHandler = TGT_UltimateGroupHandler

local _name = "TGT-CompactSwimlaneList"
local _control = TGT_CompactSwimlaneListControl
local _isActive = false
local _isCreated = false
local _controlColors = nil
local _swimlanes = {}

--[[
	Table CompactSwimlaneList
]]--
TGT_CompactSwimlaneList = {}
TGT_CompactSwimlaneList.__index = TGT_CompactSwimlaneList

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	Updates list row
]]--
local function UpdateListRow(row, player)
    local playerName = player.PlayerName
    if (_settingsHandler.SavedVariables.AccountNames) then
        playerName = GetUnitDisplayName(player.PingTag)
    end

    row:GetNamedChild("SenderNameValueLabel"):SetText(playerName)

    ZO_StatusBar_SmoothTransition(row:GetNamedChild("RelativeUltimateStatusBar"), player.RelativeUltimate, 100, false)
    ZO_StatusBar_SmoothTransition(row:GetNamedChild("RelativeStaminaStatusBar"), player.RelativeStamina, 100, false)
    ZO_StatusBar_SmoothTransition(row:GetNamedChild("RelativeMagickaStatusBar"), player.RelativeMagicka, 100, false)
    
    if (player.IsPlayerTimedOut or player.IsPlayerOnline == false) then
        -- Timeout Color
		row:GetNamedChild("SenderNameValueLabel"):SetColor(0.3, 0.3, 0.3, 1)
        row:GetNamedChild("RelativeUltimateStatusBar"):SetColor(0.3, 0.3, 0.3, _controlColors.UltiReadyColor.Background.A)
        row:GetNamedChild("RelativeStaminaStatusBar"):SetColor(0.3, 0.3, 0.3, _controlColors.StamReadyColor.Background.A)
        row:GetNamedChild("RelativeMagickaStatusBar"):SetColor(0.3, 0.3, 0.3, _controlColors.MagiReadyColor.Background.A)
	elseif (player.IsPlayerDead) then
        -- Dead Color
        row:GetNamedChild("SenderNameValueLabel"):SetColor(0.5, 0.5, 0.5, 0.8)
    else
        -- Ready Color
        if (player.RelativeUltimate == 100) then
            local ultColor = _controlColors.UltiReadyColor.Background
            local labelColor = _controlColors.UltiReadyColor.Label
            row:GetNamedChild("SenderNameValueLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
            row:GetNamedChild("RelativeUltimateStatusBar"):SetColor(ultColor.R, ultColor.G, ultColor.B, ultColor.A)
        -- Inprogress Color
        else
            local ultColor = _controlColors.UltiProgrColor.Background
            local labelColor = _controlColors.UltiProgrColor.Label
            row:GetNamedChild("SenderNameValueLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
            row:GetNamedChild("RelativeUltimateStatusBar"):SetColor(ultColor.R, ultColor.G, ultColor.B, ultColor.A)
        end

        if (player.RelativeStamina == 100) then
            local staminaColor = _controlColors.StamReadyColor.Background
            row:GetNamedChild("RelativeStaminaStatusBar"):SetColor(staminaColor.R, staminaColor.G, staminaColor.B, staminaColor.A)
        else
            local staminaColor = _controlColors.StamProgrColor.Background
            row:GetNamedChild("RelativeStaminaStatusBar"):SetColor(staminaColor.R, staminaColor.G, staminaColor.B, staminaColor.A)
        end

        if (player.RelativeMagicka == 100) then
            local magickaColor = _controlColors.MagiReadyColor.Background
            row:GetNamedChild("RelativeMagickaStatusBar"):SetColor(magickaColor.R, magickaColor.G, magickaColor.B, magickaColor.A)
        else
            local magickaColor = _controlColors.MagiProgrColor.Background
            row:GetNamedChild("RelativeMagickaStatusBar"):SetColor(magickaColor.R, magickaColor.G, magickaColor.B, magickaColor.A)
        end
	end

    -- Combat edge
    if (_settingsHandler.SavedVariables.CombatActive[GROUP_ULTIMATE] and player.IsPlayerInCombat) then
        row:GetNamedChild("RowEdge"):SetEdgeColor(0.8, 0.03, 0.03, 0.8)
    else
        row:GetNamedChild("RowEdge"):SetEdgeColor(0, 0, 0, 0.8)
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
	Fill and sorts swimlanes
]]--
local function FillAndSortSwimlane(swimlane, players)
    local swimlanePlayers = {}
    local nextFreeRow = 1
    
    for i,player in pairs(players) do
        if (player.UltimateGroup ~= nil and swimlane.UltimateGroupId == player.UltimateGroup.GroupAbilityId) then
            swimlanePlayers[nextFreeRow] = player
            nextFreeRow = nextFreeRow + 1
        end
    end
    
    if (_settingsHandler.SavedVariables.IsSortingActive) then
	    table.sort(swimlanePlayers, Compare)
    end
    
    for i=1, ROWS, 1 do
        local row = swimlane.SwimlaneControl:GetNamedChild("Row" .. i)
        local listPlayer = swimlanePlayers[i]

        if (listPlayer ~= nil) then
            row:ClearAnchors()

		    if (i == 1) then
                row:SetAnchor(TOPLEFT, swimlane.SwimlaneControl, BOTTOMLEFT, 0, 1)
            else
				row:SetAnchor(TOPLEFT, swimlane.SwimlaneControl:GetNamedChild("Row" .. (i - 1)), BOTTOMLEFT, 0, 1)
			end

            listPlayer.UltimateCompactSwimlaneRow = row
            UpdateListRow(row, listPlayer)
        else
            row:ClearAnchors()
            row:SetHidden(true)
        end
    end
end

--[[
	Sets visibility of labels
]]--
local function RefreshList()
    local functionTimestamp = GetGameTimeMilliseconds()
    local players = _playerHandler.GetRemoteGroupPlayers()

    -- Check all swimlanes
    for i,swimlane in ipairs(_swimlanes) do
        FillAndSortSwimlane(swimlane, players)
	end

    _logger:logTrace("TGT_SwimlaneList -> RefreshList", GetGameTimeMilliseconds() - functionTimestamp)
end

--[[
	Updates player
]]--
local function UpdatePlayer(player)
	if (player) then
        if (player.UltimateCompactSwimlaneRow ~= nil) then
            UpdateListRow(player.UltimateCompactSwimlaneRow, player)
        end
    end
end

--[[
	Clears player
]]--
local function ClearPlayer(player)
	if (player) then
        player.UltimateCompactSwimlaneRow = nil
    end
end

--[[
	SetControlScale sets the Scale in UI elements
]]--
local function SetControlScale()
    _control:SetScale(_settingsHandler.SavedVariables.Scale[GROUP_ULTIMATE])
end

--[[
	SetGroupResources shows/hide the GroupResources UI elements
]]--
local function SetGroupResources()
    local isGroupResourcesEnabled = _settingsHandler.SavedVariables.IsGroupResourcesEnabled

    for i,swimlane in ipairs(_swimlanes) do
        for j=1, ROWS, 1 do
            local row = swimlane.SwimlaneControl:GetNamedChild("Row" .. j)
            
            if (isGroupResourcesEnabled) then
                row:GetNamedChild("RelativeUltimateStatusBar"):ClearAnchors()
                row:GetNamedChild("RelativeUltimateStatusBar"):SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
                row:GetNamedChild("RelativeUltimateStatusBar"):SetAnchor(TOPRIGHT, row, TOPRIGHT, 0, 0)
                row:GetNamedChild("RelativeStaminaStatusBar"):SetHidden(false)
                row:GetNamedChild("RelativeMagickaStatusBar"):SetHidden(false)
            else
                row:GetNamedChild("RelativeUltimateStatusBar"):ClearAnchors()
                row:GetNamedChild("RelativeUltimateStatusBar"):SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
                row:GetNamedChild("RelativeUltimateStatusBar"):SetAnchor(BOTTOMRIGHT, row, BOTTOMRIGHT, 0, 0)
                row:GetNamedChild("RelativeStaminaStatusBar"):SetHidden(true)
                row:GetNamedChild("RelativeMagickaStatusBar"):SetHidden(true)
            end
        end
    end
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
	RestorePosition sets TGT_CompactSwimlaneList on settings position
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
    if (_settingsHandler.IsCompactSwimlaneListVisible() and _isCreated) then
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
	SetSwimlanesVisible sets swimlanes visibility on base of settings
]]--
local function SetSwimlanesVisible()
    local visibleSwimlanes = _settingsHandler.SavedVariables.Swimlanes

    for i=1, SWIMLANES, 1 do
        if (i > visibleSwimlanes) then
            _swimlanes[i].SwimlaneControl:SetHidden(true)
        else
            _swimlanes[i].SwimlaneControl:SetHidden(false)
            _control:SetWidth(_swimlanes[i].SwimlaneControl:GetRight() - _control:GetLeft())
        end
    end
end

--[[
	SetSwimlaneUltimate sets the swimlane header icon in base of ultimateGroupId
]]--
local function SetSwimlaneUltimate(swimlaneId, ultimateGroup)
    local swimlaneObject = _swimlanes[swimlaneId]
    local iconControl = swimlaneObject.SwimlaneControl:GetNamedChild("Header"):GetNamedChild("SelectorButtonControl"):GetNamedChild("Icon")

    if (ultimateGroup ~= nil and iconControl ~= nil) then
        iconControl:SetTexture(GetAbilityIcon(ultimateGroup.GroupAbilityId))

        swimlaneObject.UltimateGroupId = ultimateGroup.GroupAbilityId
    end
end

--[[
	OnSetUltimateGroup called on header clicked
]]--
local function OnSetUltimateGroup(group, swimlaneId)
    CALLBACK_MANAGER:UnregisterCallback(TGT_SET_ULTIMATE_GROUP, OnSetUltimateGroup)

    if (group ~= nil and swimlaneId ~= nil and swimlaneId >= 1 and swimlaneId <= SWIMLANES) then
        _settingsHandler.SetSwimlaneUltimateGroupIdSettings(swimlaneId, group)
    end
end

--[[
	OnSwimlaneHeaderClicked called on header clicked
]]--
local function OnSwimlaneHeaderClicked(button, swimlaneId)
    if (button ~= nil) then
        CALLBACK_MANAGER:RegisterCallback(TGT_SET_ULTIMATE_GROUP, OnSetUltimateGroup)
        FireCallbacksAsync(TGT_SHOW_ULTIMATE_GROUP_MENU, button, swimlaneId)
    end
end

--[[
	CreateCompactSwimlaneListRows creates swimlane lsit rows
]]--
local function CreateCompactSwimlaneListRows(swimlaneControl)
    if (swimlaneControl ~= nil) then
	    for i=1, ROWS, 1 do
		    local row = CreateControlFromVirtual("$(parent)Row", swimlaneControl, "CompactGroupUltimateSwimlaneRow", i)

		    row:SetHidden(true) -- initial not visible
	    end
    end
end

--[[
	CreateCompactSwimlaneListHeaders creates swimlane list headers
]]--
local function CreateCompactSwimlaneListHeaders()
	for i=1, SWIMLANES, 1 do
        local ultimateGroupId = _settingsHandler.SavedVariables.SwimlaneUltimateGroupIds[i]
        local ultimateGroup = _ultimateGroupHandler.GetUltimateGroupByAbilityId(ultimateGroupId)

        local swimlaneControlName = "Swimlane" .. tostring(i)
        local swimlaneControl = _control:GetNamedChild(swimlaneControlName)
        
        -- Add button
        local button = swimlaneControl:GetNamedChild("Header"):GetNamedChild("SelectorButtonControl"):GetNamedChild("Button")
        button:SetHandler("OnClicked", function() OnSwimlaneHeaderClicked(button, i) end)

        local swimLane = {}
        swimLane.Id = i
        swimLane.SwimlaneControl = swimlaneControl

        if (ultimateGroup ~= nil) then
            local icon = swimlaneControl:GetNamedChild("Header"):GetNamedChild("SelectorButtonControl"):GetNamedChild("Icon")
            icon:SetTexture(GetAbilityIcon(ultimateGroup.GroupAbilityId))

            swimLane.UltimateGroupId = ultimateGroup.GroupAbilityId
        end

        CreateCompactSwimlaneListRows(swimlaneControl)
	    _swimlanes[i] = swimLane
	end
end

--[[
	SetControlColor sets control color
]]--
local function SetControlColors(part)
    if (part == GROUP_ULTIMATE) then
        local ultiReadyColor = _settingsHandler.SavedVariables.ModuleColors[part].UltimateReadyColor
        local ultiProgrColor = _settingsHandler.SavedVariables.ModuleColors[part].UltimateProgrColor
        local stamReadyColor = _settingsHandler.SavedVariables.ModuleColors[part].StaminaReadyColor
        local stamProgrColor = _settingsHandler.SavedVariables.ModuleColors[part].StaminaProgrColor
        local magiReadyColor = _settingsHandler.SavedVariables.ModuleColors[part].MagickaReadyColor
        local magiProgrColor = _settingsHandler.SavedVariables.ModuleColors[part].MagickaProgrColor

        _controlColors = {
            ["UltiReadyColor"] = { ["Background"] = ultiReadyColor, ["Label"] = GetAdjustedLabelColor(ultiReadyColor) },
            ["UltiProgrColor"] = { ["Background"] = ultiProgrColor, ["Label"] = GetAdjustedLabelColor(ultiProgrColor) },
            ["StamReadyColor"] = { ["Background"] = stamReadyColor, ["Label"] = GetAdjustedLabelColor(stamReadyColor) },
            ["StamProgrColor"] = { ["Background"] = stamProgrColor, ["Label"] = GetAdjustedLabelColor(stamProgrColor) },
            ["MagiReadyColor"] = { ["Background"] = magiReadyColor, ["Label"] = GetAdjustedLabelColor(magiReadyColor) },
            ["MagiProgrColor"] = { ["Background"] = magiProgrColor, ["Label"] = GetAdjustedLabelColor(magiProgrColor) }
        }
    end
end

--[[
	SetControlActive sets hidden on control
]]--
local function SetControlActive()
    SetControlHidden()

    -- Get isActive from settings
    local isActive = _settingsHandler.IsCompactSwimlaneListVisible()

    if (_isActive ~= isActive) then
        _isActive = isActive

        if (isActive) then
            -- Workaround: To avoid "Too many anchors processed" error; Thank you ZOS for stealing hours of my life!
            if (_isCreated == false) then
                _isCreated = true
                CreateCompactSwimlaneListHeaders()
            end

            SetControlMovable()
            RestorePosition()
            SetControlColors(GROUP_ULTIMATE)
            SetSwimlanesVisible()
            SetControlScale()
            SetGroupResources()
            RefreshList()
            
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_REFRESH, RefreshList)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_OFFLINE_CHANGED, UpdatePlayer)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_CLEAR, ClearPlayer)
            CALLBACK_MANAGER:RegisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:RegisterCallback(TGT_SWIMLANE_ULTIMATE_GROUP_ID_CHANGED, SetSwimlaneUltimate)
            CALLBACK_MANAGER:RegisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
            CALLBACK_MANAGER:RegisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TGT_VISIBLE_OFFSET_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TGT_SWIMLANES_CHANGED, SetSwimlanesVisible)
            CALLBACK_MANAGER:RegisterCallback(TGT_SCALING_CHANGED, SetControlScale)
            CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_RESOURCES_ENABLED_CHANGED, SetGroupResources)
        else
            -- Start timeout timer
	        EVENT_MANAGER:UnregisterForUpdate(_name)

            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_REFRESH, RefreshList)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_OFFLINE_CHANGED, UpdatePlayer)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_CLEAR, ClearPlayer)
            CALLBACK_MANAGER:UnregisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:UnregisterCallback(TGT_SWIMLANE_ULTIMATE_GROUP_ID_CHANGED, SetSwimlaneUltimate)
            CALLBACK_MANAGER:UnregisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
            CALLBACK_MANAGER:UnregisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TGT_VISIBLE_OFFSET_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TGT_SWIMLANES_CHANGED, SetSwimlanesVisible)
            CALLBACK_MANAGER:UnregisterCallback(TGT_SCALING_CHANGED, SetControlScale)
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
	OnTGT_CompactSwimlaneListMoveStop saves current TGT_CompactSwimlaneList position to settings
]]--
function TGT_CompactSwimlaneList.OnCompactSwimlaneListMoveStop()
	local left = _control:GetLeft()
	local top = _control:GetTop()
	
    _settingsHandler.SavedVariables.Position[GROUP_ULTIMATE].PosX = left
    _settingsHandler.SavedVariables.Position[GROUP_ULTIMATE].PosY = top
end

--[[
	Initialize initializes TGT_CompactSwimlaneList
]]--
function TGT_CompactSwimlaneList.Initialize()
    _logger = TGT_LOGGER

    CALLBACK_MANAGER:RegisterCallback(TGT_STYLE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_SENDING_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_IS_ZONE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_ACTIVATED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_ULTIMATE_ENABLED_CHANGED, SetControlActive)
    
    _logger:logTrace("TGT_CompactSwimlaneList -> Initialized")
end