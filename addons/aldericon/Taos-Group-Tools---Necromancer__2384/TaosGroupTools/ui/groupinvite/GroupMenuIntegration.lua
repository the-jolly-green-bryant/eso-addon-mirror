--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local _logger = nil
local _isActive = false
local _settingsHandler = TGT_SettingsHandler
local _inviteHandler = TGT_InviteHandler

local _name = "TGT-GroupMenuIntegration"
local _container = nil
local _regroupButton = nil
local _toggleButton = nil
local _inputTextBox = nil

--[[
	Table TGT_GroupMenuIntegration
]]--
TGT_GroupMenuIntegration = {}
TGT_GroupMenuIntegration.__index = TGT_GroupMenuIntegration

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	RegroupButton OnClicked handler
]]--
local function OnRegroupButtonOnClicked()
    _inviteHandler.Regroup()
end

--[[
	SetRegroupButtonEnabled Sets regroup button enabled
]]--
local function SetRegroupButtonEnabled(isGrouped)
    local inviteString = _settingsHandler.SavedVariables.InviteString
    local isInviteStringValid = inviteString ~= nil and inviteString ~= ""
    _regroupButton:SetEnabled(isGrouped and isInviteStringValid)
end

--[[
	InputTextBox OnEnter handler
]]--
local function SetToggleButtonState(isRunning)
    _inputTextBox:GetNamedChild("Box"):SetText(_settingsHandler.SavedVariables.InviteString)
    ZO_CheckButton_SetCheckState(_toggleButton, isRunning)
end

--[[
	ToggleButton Clicked handler
]]--
local function OnToggleButtonClicked(control, checked)
    if (checked) then
        local inviteString = _settingsHandler.SavedVariables.InviteString
        local isInviteStringValid = inviteString ~= nil and inviteString ~= ""

        if (isInviteStringValid) then
            _inviteHandler.SetInviteString(_settingsHandler.SavedVariables.InviteString)
        else
            ZO_CheckButton_SetCheckState(_toggleButton, false)
            d(GetString(TGT_UI_AUTOINVITE_TEXT_ERROR))
        end
    else
        _inviteHandler.StopInvite()
    end
end

--[[
	InputTextBox OnEnter handler
]]--
local function OnInputTextBoxOnEnter()
    _settingsHandler.SetInviteString(_inputTextBox:GetNamedChild("Box"):GetText())
end

--[[
	CreateMenu creates additional invite menus
]]--
local function CreateMenu()
	-- keyboard only integration
    if(not ZO_GroupMenu_Keyboard) then return end
	
    -- create container
    _container = WINDOW_MANAGER:CreateControl("GroupInviteContainer", ZO_GroupMenu_Keyboard, CT_CONTROL)
    _container:ClearAnchors()
    _container:SetAnchor(BOTTOMLEFT, ZO_SearchingForGroup, TOPLEFT, 5, -15)
    _container:SetWidth(190)
	_container:SetHeight(95)

    -- create regroup button
    _regroupButton = CreateControlFromVirtual("$(parent)GroupInviteRegroup", _container, "ZO_DefaultButton")
    _regroupButton:SetText(GetString(TGT_UI_AUTOINVITE_REGROUP_BUTTON))
    _regroupButton:ClearAnchors()
    _regroupButton:SetAnchor(TOPLEFT, _container, TOPLEFT, 0, 0)
	_regroupButton:SetAnchor(TOPRIGHT, _container, TOPRIGHT, 0, 0)
	_regroupButton:SetClickSound("Click")
	_regroupButton.data = { tooltipText = GetString(TGT_UI_AUTOINVITE_REGROUP_BUTTON) }
	_regroupButton:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
    _regroupButton:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
    _regroupButton:SetHandler("OnClicked", OnRegroupButtonOnClicked)

    -- create toggle button
	_toggleButton = CreateControlFromVirtual("$(parent)GroupInviteToggle", _container, "ZO_CheckButton_Text")
	ZO_CheckButton_SetLabelText(_toggleButton, GetString(TGT_UI_AUTOINVITE_LABEL))
	ZO_CheckButton_SetToggleFunction(_toggleButton, OnToggleButtonClicked)
    _toggleButton:ClearAnchors()
	_toggleButton.label:SetAnchor(TOPLEFT, _regroupButton, BOTTOMLEFT, 0, 10)
	_toggleButton:SetAnchor(LEFT, _toggleButton.label, RIGHT, -40, 0)

    -- create input textbox
    _inputTextBox = CreateControlFromVirtual("$(parent)GroupInviteInput", _container, "GroupInviteEditBox")
	_inputTextBox:GetNamedChild("Box"):SetHandler("OnEnter", OnInputTextBoxOnEnter)
	_inputTextBox:GetNamedChild("Box"):SetMaxInputChars(250)
    _inputTextBox:ClearAnchors()
	_inputTextBox:SetAnchor(BOTTOMLEFT, _container, BOTTOMLEFT, 0, 0)
	_inputTextBox:SetAnchor(BOTTOMRIGHT, _container, BOTTOMRIGHT, 0, 0)
    
    SetRegroupButtonEnabled(GetIsUnitGrouped())
    SetToggleButtonState(_inviteHandler.IsRunning)

    _container:SetHidden(true)
end

--[[
	SetControlActive sets hidden on control
]]--
local function SetControlActive()
    -- Get isActive from settings
    local isActive = _settingsHandler.SavedVariables.IsGroupInviteEnabled

    if (_isActive ~= isActive) then
        _isActive = isActive

        if (isActive) then
            _container:SetHidden(false)

            CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_INVITE_RUNNING_CHANGED, SetToggleButtonState)
            CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetRegroupButtonEnabled)
        else
            _container:SetHidden(true)

            CALLBACK_MANAGER:UnregisterCallback(TGT_GROUP_INVITE_RUNNING_CHANGED, SetToggleButtonState)
            CALLBACK_MANAGER:UnregisterCallback(TAO_UNIT_GROUPED_CHANGED, SetRegroupButtonEnabled)
        end
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	Initialize initializes TGT_GroupMenuIntegration
]]--
function TGT_GroupMenuIntegration.Initialize()
    _logger = TGT_LOGGER

    CreateMenu()
    SetControlActive()

    _logger:logTrace("TGT_GroupMenuIntegration -> Initialized")
end