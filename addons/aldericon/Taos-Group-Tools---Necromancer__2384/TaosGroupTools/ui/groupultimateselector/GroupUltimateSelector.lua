--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local DEFAULT_ICON = "/esoui/art/icons/icon_missing.dds"

local _logger = nil
local _settingsHandler = TGT_SettingsHandler
local _control = TGT_UltimateSelectorControl
local _isActive = false

--[[
	Table GroupUltimateSelector
]]--
TGT_GroupUltimateSelector = {}
TGT_GroupUltimateSelector.__index = TGT_GroupUltimateSelector

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	SetUltimateIcon sets the button icon in base of staticUltimateID
]]--
local function SetUltimateIcon(staticUltimateID)
    local icon = DEFAULT_ICON

    if (staticUltimateID ~= 0) then
        icon = GetAbilityIcon(staticUltimateID)
    end

    local iconControl = _control:GetNamedChild("SelectorButtonControl"):GetNamedChild("Icon")

    if (icon ~= nil and iconControl ~= nil) then
        iconControl:SetTexture(icon)
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
	RestorePosition sets TGT_GroupUltimateSelector on settings position
]]--
local function RestorePosition()
    local posX = _settingsHandler.SavedVariables.Position[GROUP_ULTIMATE_SELECTOR].PosX
    local posY = _settingsHandler.SavedVariables.Position[GROUP_ULTIMATE_SELECTOR].PosY

	_control:ClearAnchors()
	_control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, posX, posY)
end

--[[
	OnSetUltimateGroup sets ultimate group for button
]]--
local function OnSetUltimateGroup(group)
    CALLBACK_MANAGER:UnregisterCallback(TGT_SET_ULTIMATE_GROUP, OnSetUltimateGroup)

    if (group ~= nil) then
        _settingsHandler.SetStaticUltimateIDSettings(group.GroupAbilityId)
    end
end

--[[
	SetControlHidden sets hidden on control
]]--
local function SetControlHidden()
    -- Get isActive from settings
    if (_settingsHandler.SavedVariables.IsSendingDataActive) then
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
	SetControlActive activates/deactivates control
]]--
local function SetControlActive()
    SetControlHidden()

    -- Get isActive from settings
    local isActive = _settingsHandler.SavedVariables.IsSendingDataActive

    if (_isActive ~= isActive) then
        _isActive = isActive

        if (isActive) then
            SetControlMovable()
            RestorePosition()
            SetUltimateIcon(_settingsHandler.GetStaticUltimateIDSettings())

            CALLBACK_MANAGER:RegisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:RegisterCallback(TGT_STATIC_ULTIMATE_ID_CHANGED, SetUltimateIcon)
            CALLBACK_MANAGER:RegisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
        else
            CALLBACK_MANAGER:UnregisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:UnregisterCallback(TGT_STATIC_ULTIMATE_ID_CHANGED, SetUltimateIcon)
            CALLBACK_MANAGER:UnregisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
        end
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	OnTGT_GroupUltimateSelectorMoveStop saves current TGT_GroupUltimateSelector position to settings
]]--
function TGT_GroupUltimateSelector.OnGroupUltimateSelectorMoveStop()
	local left = _control:GetLeft()
	local top = _control:GetTop()
	
    _settingsHandler.SavedVariables.Position[GROUP_ULTIMATE_SELECTOR].PosX = left
    _settingsHandler.SavedVariables.Position[GROUP_ULTIMATE_SELECTOR].PosY = top
end

--[[
	OnGroupUltimateSelectorClicked shows ultimate group menu
]]--
function TGT_GroupUltimateSelector.OnGroupUltimateSelectorClicked()
    local button = _control:GetNamedChild("SelectorButtonControl"):GetNamedChild("Button")

    if (button ~= nil) then
        CALLBACK_MANAGER:RegisterCallback(TGT_SET_ULTIMATE_GROUP, OnSetUltimateGroup)
        FireCallbacksAsync(TGT_SHOW_ULTIMATE_GROUP_MENU, button)
    end
end

--[[
	Initialize initializes TGT_GroupUltimateSelector
]]--
function TGT_GroupUltimateSelector.Initialize()
    _logger = TGT_LOGGER

    SetUltimateIcon(staticUltimateID)
    SetControlActive()

    CALLBACK_MANAGER:RegisterCallback(TGT_IS_ZONE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_SENDING_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_ACTIVATED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_ULTIMATE_ENABLED_CHANGED, SetControlActive)
    
    _logger:logTrace("TGT_GroupUltimateSelector -> Initialized")
end