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

local _control = TGT_CustomizedCompassControl
local _compassLabels = {
    [1] = _control:GetNamedChild("North"),
    [2] = _control:GetNamedChild("East"),
    [3] = _control:GetNamedChild("South"),
    [4] = _control:GetNamedChild("West"),
}
local _isActive = false

--[[
	Table TGT_CustomizedCompass
]]--
TGT_CustomizedCompass = {}
TGT_CustomizedCompass.__index = TGT_CustomizedCompass

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	UpdateCompassAngle updates rotation of compass
]]--
local function UpdateCompassAngle()
    local angle, posX, posY
    local radius = _settingsHandler.SavedVariables.CompassRadius
    local flatCompass = _settingsHandler.SavedVariables.FlatCompass
    local compassFontSize = _settingsHandler.SavedVariables.CompassFontSize

	for i = 1, 4 do
		angle = (i - 2) * math.pi / 2 + GetPlayerCameraHeading()
		posX = zo_round(radius * math.cos(angle))
		posY = zo_round(radius * math.sin(angle))
        
        if (flatCompass) then
            if (posY >= compassFontSize) then
                _compassLabels[i]:SetHidden(true)
            else
                _compassLabels[i]:SetHidden(false)
            end
            
            posY = 0
        end

		_compassLabels[i]:ClearAnchors()
		_compassLabels[i]:SetAnchor(CENTER, _control, CENTER, posX, posY)
	end
end

--[[
	SetControlColors sets control color
]]--
local function SetControlColors(part)
    if (part == GROUP_LEADER) then
        local controlColor = _settingsHandler.SavedVariables.ModuleColors[part].CompassColor

        _control:GetNamedChild("North"):SetColor(controlColor.R, controlColor.G, controlColor.B, controlColor.A)
        _control:GetNamedChild("East"):SetColor(controlColor.R, controlColor.G, controlColor.B, controlColor.A)
        _control:GetNamedChild("South"):SetColor(controlColor.R, controlColor.G, controlColor.B, controlColor.A)
        _control:GetNamedChild("West"):SetColor(controlColor.R, controlColor.G, controlColor.B, controlColor.A)
    end
end

--[[
	SetControlSize sets control size
]]--
local function SetControlSize()
    local radius = _settingsHandler.SavedVariables.CompassRadius
    local flatCompass = _settingsHandler.SavedVariables.FlatCompass
    local compassFontSize = _settingsHandler.SavedVariables.CompassFontSize

    if (flatCompass) then
        _control:SetDimensions(radius * 2, compassFontSize)
    else
        _control:SetDimensions(radius * 2, radius * 2)
    end
end

--[[
	SetControlFont sets control font
]]--
local function SetControlFont()
    local fontIndex = _settingsHandler.SavedVariables.CompassFont
    local compassFont = _settingsHandler.CompassFonts[fontIndex].fontName
    local compassFontSize = _settingsHandler.SavedVariables.CompassFontSize
    local face = _G[compassFont]:GetFontInfo()
    local shadowStyle = "soft-shadow-thick"
    if (compassFontSize <= 14) then
        shadowStyle = "soft-shadow-thin"
    end
    local fontSizeString = CHAT_SYSTEM:GetFontSizeString(compassFontSize)
    local fontFormatString = ("%s|%s|%s"):format(face, fontSizeString, shadowStyle)

    _control:GetNamedChild("North"):SetFont(fontFormatString)
    _control:GetNamedChild("East"):SetFont(fontFormatString)
    _control:GetNamedChild("South"):SetFont(fontFormatString)
    _control:GetNamedChild("West"):SetFont(fontFormatString)

    SetControlSize()
end

--[[
	SetControlStyle Updates control
]]--
local function SetControlStyle()
    local flatCompass = _settingsHandler.SavedVariables.FlatCompass

    if (flatCompass == false) then
        _control:GetNamedChild("North"):SetHidden(false)
        _control:GetNamedChild("East"):SetHidden(false)
        _control:GetNamedChild("South"):SetHidden(false)
        _control:GetNamedChild("West"):SetHidden(false)
    end

    SetControlSize()
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
	RestorePosition sets on settings position
]]--
local function RestorePosition()
    local posX = _settingsHandler.SavedVariables.Position[GROUP_LEADER].PosX
    local posY = _settingsHandler.SavedVariables.Position[GROUP_LEADER].PosY

	_control:ClearAnchors()
	_control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, posX, posY)
end

--[[
	HideStandardCompass sets hidden on standard compass controls
]]--
local function HideStandardCompass()
    local isActive = _settingsHandler.SavedVariables.IsCustomizedCompassActive
    local hideStandardCompass = _settingsHandler.SavedVariables.HideStandardCompass

    if (hideStandardCompass and isActive and GetIsUnitGrouped()) then
	    ZO_CompassCenterOverPinLabel:SetHidden(true)
	    ZO_CompassContainer:SetHidden(true)
	    ZO_CompassFrameLeft:SetHidden(true)
	    ZO_CompassFrameCenter:SetHidden(true)
	    ZO_CompassFrameRight:SetHidden(true)
    else
	    ZO_CompassCenterOverPinLabel:SetHidden(false)
	    ZO_CompassContainer:SetHidden(false)
	    ZO_CompassFrameLeft:SetHidden(false)
	    ZO_CompassFrameCenter:SetHidden(false)
	    ZO_CompassFrameRight:SetHidden(false)
    end
end

--[[
	SetControlHidden sets hidden on control
]]--
local function SetControlHidden()
    local isActive = _settingsHandler.SavedVariables.IsCustomizedCompassActive

    -- Only show if control is active, player is grouped
    if (isActive and GetIsUnitGrouped()) then
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
    HideStandardCompass()

    local isActive = _settingsHandler.SavedVariables.IsCustomizedCompassActive
    
    if (_isActive ~= isActive) then
        _isActive = isActive

        if (isActive) then
            SetControlMovable()
            RestorePosition()
            SetControlFont() -- Calls SetControlSize()
            SetControlColors(GROUP_LEADER)

            CALLBACK_MANAGER:RegisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, HideStandardCompass)
            CALLBACK_MANAGER:RegisterCallback(TGT_COMPASS_ZOS_COMPASS_CHANGED, HideStandardCompass)
            CALLBACK_MANAGER:RegisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:RegisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
            CALLBACK_MANAGER:RegisterCallback(TGT_COMPASS_RADIUS_CHANGED, SetControlSize)
            CALLBACK_MANAGER:RegisterCallback(TGT_COMPASS_FONT_CHANGED, SetControlFont)
            CALLBACK_MANAGER:RegisterCallback(TGT_COMPASS_FLAT_CHANGED, SetControlStyle)
        else
            CALLBACK_MANAGER:UnregisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TAO_UNIT_GROUPED_CHANGED, HideStandardCompass)
            CALLBACK_MANAGER:UnregisterCallback(TGT_COMPASS_ZOS_COMPASS_CHANGED, HideStandardCompass)
            CALLBACK_MANAGER:UnregisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:UnregisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
            CALLBACK_MANAGER:UnregisterCallback(TGT_COMPASS_RADIUS_CHANGED, SetControlSize)
            CALLBACK_MANAGER:UnregisterCallback(TGT_COMPASS_FONT_CHANGED, SetControlFont)
            CALLBACK_MANAGER:UnregisterCallback(TGT_COMPASS_FLAT_CHANGED, SetControlStyle)
        end
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	OnUpdateControl updates position of compass
]]--
function TGT_CustomizedCompass_OnUpdate()
    -- If UI visible, the method will be called every frame
    UpdateCompassAngle()
end

--[[
	TGT_DpsHpsBarList_OnMoveStop saves position
]]--
function TGT_CustomizedCompass_OnMoveStop(control)
    _settingsHandler.SavedVariables.Position[GROUP_LEADER].PosX = control:GetLeft()
    _settingsHandler.SavedVariables.Position[GROUP_LEADER].PosY = control:GetTop()
end

--[[
	Initialize initializes TGT_CustomizedCompass
]]--
function TGT_CustomizedCompass.Initialize()
    _logger = TGT_LOGGER

    _control:GetNamedChild("North"):SetText(GetString(SI_COMPASS_NORTH_ABBREVIATION))
    _control:GetNamedChild("East"):SetText(GetString(SI_COMPASS_EAST_ABBREVIATION))
    _control:GetNamedChild("South"):SetText(GetString(SI_COMPASS_SOUTH_ABBREVIATION))
    _control:GetNamedChild("West"):SetText(GetString(SI_COMPASS_WEST_ABBREVIATION))

    SetControlActive()
    
    CALLBACK_MANAGER:RegisterCallback(TGT_COMPASS_ACTIVE_CHANGED, SetControlActive)
    
    _logger:logTrace("TGT_CustomizedCompass -> Initialized")
end