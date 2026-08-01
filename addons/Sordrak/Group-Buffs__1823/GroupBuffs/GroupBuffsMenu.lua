-- GroupBuffs - Menu
-- By @s0rdrak, @Graham82 (PC / EU)

--local LAM = LibStub("LibAddonMenu-2.0")
local LAM = LibAddonMenu2

local GroupBuffs = _G['GroupBuffs']
local GroupBuffsMenu = GroupBuffs.menu

local wm = GetWindowManager()

GroupBuffsMenu.lam = {}
GroupBuffsMenu.lam.panel = nil
GroupBuffsMenu.lam.panelData = {}
GroupBuffsMenu.lam.panelData.type = "panel"
GroupBuffsMenu.lam.panelData.name = "|c4592FFGroup Buffs|r"
GroupBuffsMenu.lam.panelData.displayName = GroupBuffs.config.constants.menu.DISPLAY_NAME
GroupBuffsMenu.lam.panelData.author = GroupBuffs.config.constants.menu.AUTHOR
GroupBuffsMenu.lam.panelData.version = GroupBuffs.config.constants.menu.VERSION
--GroupBuffsMenu.lam.panelData.slashCommand = "/gbmenu"
GroupBuffsMenu.lam.panelData.registerForRefresh = true
GroupBuffsMenu.lam.panelData.registerForDefaults = false

GroupBuffsMenu.localValues = {}
GroupBuffsMenu.localValues.newFrameName = ""
GroupBuffsMenu.localValues.selectedFrameName = nil
GroupBuffsMenu.localValues.frameNamesInitialized = false
GroupBuffsMenu.localValues.newBuffName = ""
GroupBuffsMenu.localValues.selectedBuffId = nil
GroupBuffsMenu.localValues.buffNamesInitialized = false
GroupBuffsMenu.localValues.selectedBuffEffectId = nil
GroupBuffsMenu.localValues.buffEffectIdsInitialized = false

GroupBuffsMenu.constants = {}
GroupBuffsMenu.constants.references = {}
GroupBuffsMenu.constants.references.DESCRIPTION_NEW_FRAME_ERROR = "GroupBuffsMenuNewFrameErrorDescription"
GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_ERROR = "GroupBuffsMenuNewBuffErrorDescription"
GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_EFFECT_ERROR = "GroupBuffsMenuBuffEffectErrorDescription"
GroupBuffsMenu.constants.references.DROPDOWN_FRAME_NAMES = "GroupBuffsMenuFrameNamesDropdown"
GroupBuffsMenu.constants.references.DROPDOWN_DISPLAY = "GroupBuffsMenuDisplayNamesDropdown"
GroupBuffsMenu.constants.references.DROPDOWN_ROLES = "GroupBuffsMenuRolesNamesDropdown"
GroupBuffsMenu.constants.references.DROPDOWN_BUFF_NAMES = "GroupBuffsMenuBuffNamesDropdown"
GroupBuffsMenu.constants.references.DROPDOWN_BUFF_EFFECT_ID = "GroupBuffsMenuBuffEffectIdDropdown"


function GroupBuffsMenu.Initialize(menuName, vars)
	GroupBuffs.data.Initialize()
	GroupBuffsMenu.lam.optionsData = GroupBuffsMenu.CreateMenuFromVars(vars)
	GroupBuffsMenu.lam.panel = LAM:RegisterAddonPanel(menuName, GroupBuffsMenu.lam.panelData)
	LAM:RegisterOptionControls(menuName, GroupBuffsMenu.lam.optionsData)
	

end

function GroupBuffsMenu.OpenMenu()
	LAM:OpenToPanel(GroupBuffsMenu.lam.panel)
end

function GroupBuffsMenu.CallGroupBuffsGetterFunction(callback, value, defaultRetValue)
	local defRetVal = true
	if defaultRetValue ~= nil then
		defRetVal = defaultRetValue
	end
	if type(callback) == "function" then
		local retVal = callback(value)
		if retVal == nil then
			return defRetVal
		else
			return retVal
		end	
	end
	return defRetVal
end

function GroupBuffsMenu.GetNewFrameName()
	return GroupBuffsMenu.localValues.newFrameName
end

function GroupBuffsMenu.SetNewFrameName(value)
	GroupBuffsMenu.localValues.newFrameName = value
end

function GroupBuffsMenu.GetNewBuffName()
	return GroupBuffsMenu.localValues.newBuffName
end

function GroupBuffsMenu.SetNewBuffName(value)
	GroupBuffsMenu.localValues.newBuffName = value
end

function GroupBuffsMenu.GetFrameNames()
	return GroupBuffs.GetFrameNames()
end

function GroupBuffsMenu.GetFrameName()
	if GroupBuffsMenu.localValues.frameNamesInitialized == false then
		GroupBuffsMenu.localValues.frameNamesInitialized = true
	end
	local frameNames = GroupBuffsMenu.GetFrameNames()
	if GroupBuffsMenu.localValues.selectedFrameName ~= nil and GroupBuffs.TableContainsValue(frameNames, GroupBuffsMenu.localValues.selectedFrameName) then
		return GroupBuffsMenu.localValues.selectedFrameName
	elseif frameNames ~= nil and #frameNames > 0 then
		return GroupBuffsMenu.SetSelectedFrameName(frameNames[1])
	end
	
end

function GroupBuffsMenu.SetErrorMessage(controlName, errorMessage)
	local errorDescription = wm:GetControlByName(controlName)
	if errorDescription ~= nil and errorDescription.data ~= nil then
		errorDescription.data.text = errorMessage
		errorDescription:UpdateValue()
	end
end

function GroupBuffsMenu.UpdateFrameDropdown()
	local frameNames = GroupBuffsMenu.GetFrameNames()
	local dropdownControl = wm:GetControlByName(GroupBuffsMenu.constants.references.DROPDOWN_FRAME_NAMES)
	if dropdownControl ~= nil then
		dropdownControl:UpdateChoices(frameNames)
	end
end

function GroupBuffsMenu.AddFrame()
	local newFrameName = GroupBuffsMenu.GetNewFrameName()
	if newFrameName ~= nil and GroupBuffs.isUniqueFrameName(newFrameName) then
		GroupBuffsMenu.SetNewFrameName("")
		GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_FRAME_ERROR, "")
		GroupBuffs.AddNewFrame(newFrameName)
		
		GroupBuffsMenu.UpdateFrameDropdown()
		GroupBuffsMenu.localValues.selectedFrameName = newFrameName

	else
		GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_FRAME_ERROR, GroupBuffs.config.constants.menu.ERROR_UNIQUE_FRAME_NAME)
	end
end

function GroupBuffsMenu.RemoveFrame()
	if GroupBuffsMenu.localValues.selectedFrameName ~= nil then
		GroupBuffs.RemoveFrame(GroupBuffsMenu.localValues.selectedFrameName)
		GroupBuffsMenu.UpdateFrameDropdown()
	end
	GroupBuffsMenu.localValues.selectedFrameName = nil
end

function GroupBuffsMenu.SetSelectedFrameName(value)
	GroupBuffsMenu.localValues.selectedFrameName = value
	GroupBuffsMenu.UpdateBuffDropDown()
	return value
end

function GroupBuffsMenu.UpdateBuffDropDown()
	local groupBuffs, indexTable = GroupBuffs.GetBuffNames(GroupBuffsMenu.localValues.selectedFrameName)
	if groupBuffs ~= nil or indexTable ~= nil then
		local dropdownControl = wm:GetControlByName(GroupBuffsMenu.constants.references.DROPDOWN_BUFF_NAMES)
		if dropdownControl ~= nil then
			dropdownControl:UpdateChoices(groupBuffs, indexTable)
			GroupBuffsMenu.localValues.selectedBuffId = nil
		end
	end
end

function GroupBuffsMenu.GetDisplayModesValues()
	return GroupBuffs.GetDisplayModesValues()
end

function GroupBuffsMenu.GetDisplayModes()
	return GroupBuffs.GetDisplayModes()
end

function GroupBuffsMenu.GetDisplayMode()
	return GroupBuffs.GetDisplayMode(GroupBuffsMenu.localValues.selectedFrameName)
end

function GroupBuffsMenu.SetSelectedDisplayMode(value)
	GroupBuffs.SetSelectedDisplayMode(GroupBuffsMenu.localValues.selectedFrameName, value)
end

function GroupBuffsMenu.GetRoleModes()
	return GroupBuffs.GetRoleModes()
end

function GroupBuffsMenu.GetRoleModesValues()
	return GroupBuffs.GetRoleModesValues()
end

function GroupBuffsMenu.GetRoleMode()
	return GroupBuffs.GetRoleMode(GroupBuffsMenu.localValues.selectedFrameName)
end

function GroupBuffsMenu.SetSelectedRoleMode(value)
	GroupBuffs.SetSelectedRoleMode(GroupBuffsMenu.localValues.selectedFrameName, value)
end

function GroupBuffsMenu.GetBuffNames()
	return GroupBuffs.GetBuffNames(GroupBuffsMenu.localValues.selectedFrameName)
end

function GroupBuffsMenu.GetBuffName()
	if GroupBuffsMenu.localValues.buffNamesInitialized == false then
		GroupBuffsMenu.localValues.buffNamesInitialized = true
		GroupBuffsMenu.UpdateBuffDropDown()
	end
	local buffNames, indexTable = GroupBuffsMenu.GetBuffNames()
	local retVal = nil
	if GroupBuffsMenu.localValues.selectedBuffId ~= nil and GroupBuffs.TableContainsValue(indexTable, GroupBuffsMenu.localValues.selectedBuffId) then
		retVal = GroupBuffsMenu.localValues.selectedBuffId
	elseif buffNames ~= nil and #buffNames > 0 and indexTable ~= nil and #indexTable > 0 then
		GroupBuffsMenu.localValues.selectedBuffId = indexTable[1]
		GroupBuffsMenu.UpdateBuffEffectIdDropdown()
		retVal = indexTable[1]
	end
	return retVal
end

function GroupBuffsMenu.SetBuffName(value)
	GroupBuffsMenu.localValues.selectedBuffId = value
	GroupBuffsMenu.UpdateBuffEffectIdDropdown()
end

function GroupBuffsMenu.AddBuff()
	local frameName = GroupBuffsMenu.GetFrameName()
	local newBuffName = GroupBuffsMenu.GetNewBuffName()
	if frameName ~= nil and newBuffName ~= nil then
		GroupBuffsMenu.SetNewBuffName("")
		GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_ERROR, "")
		GroupBuffs.AddNewBuff(frameName, newBuffName)
		GroupBuffsMenu.UpdateBuffDropDown()
	else
		if frameName == nil then
			GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_ERROR, GroupBuffs.config.constants.menu.ERROR_NO_FRAME_NAME)
		else
			GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_ERROR, GroupBuffs.config.constants.menu.ERROR_NO_BUFF_NAME)
		end
	end
end

function GroupBuffsMenu.RemoveBuff()
	if GroupBuffsMenu.localValues.selectedFrameName ~= nil and GroupBuffsMenu.localValues.selectedBuffId ~= nil then
		GroupBuffs.RemoveBuff(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
		GroupBuffsMenu.UpdateBuffDropDown()
	end
	GroupBuffsMenu.localValues.selectedBuffId = nil
end

function GroupBuffsMenu.GetFrameIsEnabled()
	return GroupBuffsMenu.CallGroupBuffsGetterFunction(GroupBuffs.GetIsFrameEnabled, GroupBuffsMenu.localValues.selectedFrameName)
end

function GroupBuffsMenu.SetFrameIsEnabled(value)
	GroupBuffs.SetIsFrameEnabled(GroupBuffsMenu.localValues.selectedFrameName, value)
end

function GroupBuffsMenu.GetFrameIsFixedLocation()
	return not GroupBuffsMenu.CallGroupBuffsGetterFunction(GroupBuffs.GetIsFrameFixedLocation, GroupBuffsMenu.localValues.selectedFrameName)
end

function GroupBuffsMenu.SetFrameIsFixedLocation(value)
	GroupBuffs.SetIsFrameFixedLocation(GroupBuffsMenu.localValues.selectedFrameName, not value)
end

function GroupBuffsMenu.GetFrameIsPvpEnabled()
	return GroupBuffsMenu.CallGroupBuffsGetterFunction(GroupBuffs.GetIsFramePvpEnabled, GroupBuffsMenu.localValues.selectedFrameName)
end

function GroupBuffsMenu.SetFrameIsPvpEnabled(value)
	GroupBuffs.SetIsFramePvpEnabled(GroupBuffsMenu.localValues.selectedFrameName, value)
end

function GroupBuffsMenu.GetFrameIsPveEnabled()
	return GroupBuffsMenu.CallGroupBuffsGetterFunction(GroupBuffs.GetIsFramePveEnabled, GroupBuffsMenu.localValues.selectedFrameName)
end

function GroupBuffsMenu.SetFrameIsPveEnabled(value)
	GroupBuffs.SetIsFramePveEnabled(GroupBuffsMenu.localValues.selectedFrameName, value)
end

function GroupBuffsMenu.GetFrameBuffSpacing()
	return GroupBuffsMenu.CallGroupBuffsGetterFunction(GroupBuffs.GetFrameBuffSpacing, GroupBuffsMenu.localValues.selectedFrameName, 15)
end

function GroupBuffsMenu.SetFrameBuffSpacing(value)
	GroupBuffs.SetFrameBuffSpacing(GroupBuffsMenu.localValues.selectedFrameName, value)
end

function GroupBuffsMenu.GetFrameHeaderColor()
	local color = GroupBuffsMenu.CallGroupBuffsGetterFunction(GroupBuffs.GetFrameHeaderColor, GroupBuffsMenu.localValues.selectedFrameName, GroupBuffs.GetDefaultHeaderColor())
	return color.R, color.G, color.B
end

function GroupBuffsMenu.SetFrameHeaderColor(R, G, B, A)
	local color = {}
	color.R = R
	color.G = G
	color.B = B
	GroupBuffs.SetFrameHeaderColor(GroupBuffsMenu.localValues.selectedFrameName, color)
end

function GroupBuffsMenu.GetShowBuffName()
	return GroupBuffs.GetShowBuffName(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.SetShowBuffName(value)
	GroupBuffs.SetShowBuffName(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, value)
end

function GroupBuffsMenu.GetShowBuffStack()
	return GroupBuffs.GetShowBuffStack(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.SetShowBuffStack(value)
	GroupBuffs.SetShowBuffStack(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, value)
end

function GroupBuffsMenu.GetShowBuffSDifferentOffDeadColor()
	return GroupBuffs.GetShowBuffSDifferentOffDeadColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.SetShowBuffSDifferentOffDeadColor(value)
	GroupBuffs.SetShowBuffSDifferentOffDeadColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, value)
end

function GroupBuffsMenu.GetBuffDifferentOffDeadColor()
	local retVal =  GroupBuffs.GetBuffDifferentOffDeadColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
	return retVal.R, retVal.G, retVal.B
end

function GroupBuffsMenu.SetBuffDifferentOffDeadColor(R, G, B)
	local color = {}
	color.R = R
	color.G = G
	color.B = B
	GroupBuffs.SetBuffDifferentOffDeadColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, color)
end

function GroupBuffsMenu.GetAlwaysShowName()
	return GroupBuffs.GetAlwaysShowName(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.SetAlwaysShowName(value)
	GroupBuffs.SetAlwaysShowName(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, value)
end

function GroupBuffsMenu.GetBuffColumnSize()
	return GroupBuffs.GetBuffColumnSize(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.SetBuffColumnSize(value)
	GroupBuffs.SetBuffColumnSize(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, value)
end

function GroupBuffsMenu.GetOrderChoices()
	return GroupBuffs.GetOrderChoices()
end

function GroupBuffsMenu.GetOrderChoicesValues()
	return GroupBuffs.GetOrderChoicesValues()
end

function GroupBuffsMenu.GetOrder()
	return GroupBuffs.GetOrder(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.SetOrder(value)
	GroupBuffs.SetOrder(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, value)
end

function GroupBuffsMenu.UpdateBuffEffectIdDropdown()
	local indexTable = GroupBuffsMenu.GetBuffEffectIdChoices()
	if indexTable ~= nil then
		local dropdownControl = wm:GetControlByName(GroupBuffsMenu.constants.references.DROPDOWN_BUFF_EFFECT_ID)
		if dropdownControl ~= nil then
			dropdownControl:UpdateChoices(indexTable)
			GroupBuffsMenu.localValues.selectedBuffEffectId = nil
		end
	end
end

function GroupBuffsMenu.GetBuffEffectIdChoices()
	return GroupBuffs.GetBuffEffectIdChoices(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.GetBuffEffectId()
	if GroupBuffsMenu.localValues.buffEffectIdsInitialized == false then
		GroupBuffsMenu.localValues.buffEffectIdsInitialized = true
		GroupBuffsMenu.UpdateBuffEffectIdDropdown()
	end
	local indexTable = GroupBuffsMenu.GetBuffEffectIdChoices()
	if GroupBuffsMenu.localValues.selectedBuffEffectId ~= nil and GroupBuffs.TableContainsValue(indexTable, GroupBuffsMenu.localValues.selectedBuffEffectId) then
		return GroupBuffsMenu.localValues.selectedBuffEffectId
	elseif indexTable ~= nil and #indexTable > 0 then
		GroupBuffsMenu.localValues.selectedBuffEffectId = indexTable[1]
		return indexTable[1]
	end
end

function GroupBuffsMenu.SetBuffEffectId(value)
	GroupBuffsMenu.localValues.selectedBuffEffectId = value
end

function GroupBuffsMenu.AddBuffEffect()
	if GroupBuffsMenu.localValues.selectedFrameName ~= nil and GroupBuffsMenu.localValues.selectedBuffId ~= nil then
		GroupBuffs.AddBuffEffect(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
		GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_EFFECT_ERROR, "")
		GroupBuffsMenu.UpdateBuffEffectIdDropdown()
		local indexTable = GroupBuffsMenu.GetBuffEffectIdChoices()
		GroupBuffsMenu.localValues.selectedBuffEffectId = indexTable[#indexTable]
	else
		if GroupBuffsMenu.localValues.selectedFrameName == nil then
			GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_EFFECT_ERROR, GroupBuffs.config.constants.menu.ERROR_NO_FRAME_NAME)
		else
			GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_EFFECT_ERROR, GroupBuffs.config.constants.menu.ERROR_NO_BUFF_NAME)
		end
	end
end

function GroupBuffsMenu.RemoveBuffEffect()
	if GroupBuffs.RemoveBuffEffect(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, GroupBuffsMenu.localValues.selectedBuffEffectId) == true then
		GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_EFFECT_ERROR, "")
		local tempIndex = GroupBuffsMenu.localValues.selectedBuffEffectId
		GroupBuffsMenu.UpdateBuffEffectIdDropdown()
		local indexTable = GroupBuffsMenu.GetBuffEffectIdChoices()
		if tempIndex >= #indexTable then
			GroupBuffsMenu.localValues.selectedBuffEffectId = indexTable[#indexTable]
		else
			GroupBuffsMenu.localValues.selectedBuffEffectId = tempIndex
		end
	else
		GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_EFFECT_ERROR, GroupBuffs.config.constants.menu.ERROR_BUFF_EFFECT_MINIMUM)
	end
end

function GroupBuffsMenu.GetBuffEffectColor()
	local retVal = GroupBuffs.GetBuffEffectColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, GroupBuffsMenu.localValues.selectedBuffEffectId)
	return retVal.R, retVal.G, retVal.B
end

function GroupBuffsMenu.SetBuffEffectColor(R, G, B, A)
	local color = {}
	color.R = R
	color.G = G
	color.B = B
	GroupBuffs.SetBuffEffectColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, GroupBuffsMenu.localValues.selectedBuffEffectId, color)
end

function GroupBuffsMenu.GetBuffEffectFontColor()
	local retVal = GroupBuffs.GetBuffEffectFontColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, GroupBuffsMenu.localValues.selectedBuffEffectId)
	return retVal.R, retVal.G, retVal.B
end

function GroupBuffsMenu.SetBuffEffectFontColor(R, G, B, A)
	local color = {}
	color.R = R
	color.G = G
	color.B = B
	GroupBuffs.SetBuffEffectFontColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, GroupBuffsMenu.localValues.selectedBuffEffectId, color)
end

function GroupBuffsMenu.GetEffectFadeInDuration()
	return GroupBuffs.GetEffectFadeInDuration(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.SetEffectFadeInDuration(value)
	GroupBuffs.SetEffectFadeInDuration(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, value)
end

function GroupBuffsMenu.GetEffectFadeInColor()
	local retVal = GroupBuffs.GetEffectFadeInColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
	return retVal.R, retVal.G, retVal.B
end

function GroupBuffsMenu.SetEffectFadeInColor(R, G, B, A)
	local color = {}
	color.R = R
	color.G = G
	color.B = B
	GroupBuffs.SetEffectFadeInColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, color)
end

function GroupBuffsMenu.GetEffectFadeOutDuration()
	return GroupBuffs.GetEffectFadeOutDuration(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.SetEffectFadeOutDuration(value)
	GroupBuffs.SetEffectFadeOutDuration(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, value)
end

function GroupBuffsMenu.GetEffectFadeOutColor()
	local retVal = GroupBuffs.GetEffectFadeOutColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
	return retVal.R, retVal.G, retVal.B
end

function GroupBuffsMenu.SetEffectFadeOutColor(R, G, B, A)
	local color = {}
	color.R = R
	color.G = G
	color.B = B
	GroupBuffs.SetEffectFadeOutColor(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, color)
end

function GroupBuffsMenu.GetBuffEffectNames()
	return GroupBuffs.GetBuffEffectNames()
end

function GroupBuffsMenu.GetBuffEffectName()
	return GroupBuffs.GetBuffEffectName(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, GroupBuffsMenu.localValues.selectedBuffEffectId)
end

function GroupBuffsMenu.SetBuffEffectName(value)
	GroupBuffs.SetBuffEffectName(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, GroupBuffsMenu.localValues.selectedBuffEffectId, value)
end

function GroupBuffsMenu.GetActiveSoundEffect()
	return GroupBuffs.GetActiveSoundEffect(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.SetActiveSoundEffect(value)
	GroupBuffs.SetActiveSoundEffect(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, value)
end

function GroupBuffsMenu.GetEffectAudioInterval()
	return GroupBuffs.GetEffectAudioInterval(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.SetEffectAudioInterval(value)
	GroupBuffs.SetEffectAudioInterval(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, value)
end

function GroupBuffsMenu.GetAudioEffectNames()
	return GroupBuffs.GetAudioEffectNames()
end

function GroupBuffsMenu.GetAudioEffectValues()
	return GroupBuffs.GetAudioEffectValues()
end

function GroupBuffsMenu.GetAudioEffectName()
	return GroupBuffs.GetAudioEffectName(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId)
end

function GroupBuffsMenu.SetAudioEffectName(value)
	GroupBuffs.PlaySound(value)
	GroupBuffs.SetAudioEffectName(GroupBuffsMenu.localValues.selectedFrameName, GroupBuffsMenu.localValues.selectedBuffId, value)
end

function GroupBuffsMenu.CreateMenuFromVars(vars)
	return { 
		[1] = {
			type = "header",
			name = GroupBuffs.config.constants.menu.TITLE,
			width = "full",	
		},
		[2] = {
			type = "description",
			title = nil,
			text = GroupBuffs.config.constants.menu.DESCRIPTION,
			width = "full"
		},
		[3] = {
			type = "checkbox",
			name = GroupBuffs.config.constants.menu.ADDON_ENABLED,
			getFunc = GroupBuffs.GetAddonState,
			setFunc = GroupBuffs.ChangeAddonState	
		},
		[4] = {
			type = "header",
			name = GroupBuffs.config.constants.menu.HEADER_FRAME_CONFIGURATION,
			width = "full",	
		},
		[5] = {
			type = "description",
			title = nil,
			text = GroupBuffs.config.constants.menu.FRAME_DESCRIPTION,
			width = "full"
		},
		[6] = {
			type = "editbox",
			name = GroupBuffs.config.constants.menu.NEW_FRAME,
			tooltip = nil,
			getFunc = GroupBuffsMenu.GetNewFrameName,
			setFunc = GroupBuffsMenu.SetNewFrameName,
			isMultiline = false,
			width = "full",
			warning = nil,
			default = ""
		},
		[7] = {
			type = "button",
			name = GroupBuffs.config.constants.menu.ADD_FRAME,
			tooltip = GroupBuffs.config.constants.menu.ADD_FRAME_TOOLTIP,
			func = GroupBuffsMenu.AddFrame,
			width = "full"
		},
		[8] = {
			type = "description",
			title = nil,
			text = "",
			width = "full",
			reference = GroupBuffsMenu.constants.references.DESCRIPTION_NEW_FRAME_ERROR
		},
		[9] = {
			type = "divider",
			width = "full"
		},
		[10] = {
			type = "description",
			title = nil,
			text = GroupBuffs.config.constants.menu.SELECT_FRAME,
			width = "full"
		},
		[11] = {
			type = "dropdown",
			name = GroupBuffs.config.constants.menu.FRAME,
			tooltip = GroupBuffs.config.constants.menu.SELECT_FRAME_TOOLTIP,
			choices = GroupBuffsMenu.GetFrameNames(),
			getFunc = GroupBuffsMenu.GetFrameName ,
			setFunc = GroupBuffsMenu.SetSelectedFrameName ,
			reference = GroupBuffsMenu.constants.references.DROPDOWN_FRAME_NAMES
		},
		[12] = {
			type = "button",
			name = GroupBuffs.config.constants.menu.REMOVE_FRAME,
			func = GroupBuffsMenu.RemoveFrame,
			width = "full",
			warning = GroupBuffs.config.constants.menu.REMOVE_FRAME_WARNING
		},
		[13] = {
			type = "checkbox",
			name = GroupBuffs.config.constants.menu.FRAME_ENABLED,
			getFunc = GroupBuffsMenu.GetFrameIsEnabled,
			setFunc = GroupBuffsMenu.SetFrameIsEnabled
		},
		[14] = {
			type = "checkbox",
			name = GroupBuffs.config.constants.menu.FRAME_FIXED_LOCATION,
			getFunc = GroupBuffsMenu.GetFrameIsFixedLocation,
			setFunc = GroupBuffsMenu.SetFrameIsFixedLocation		
		},
		[15] = {
			type = "checkbox",
			name = GroupBuffs.config.constants.menu.ENABLED_IN_PVP,
			getFunc = GroupBuffsMenu.GetFrameIsPvpEnabled,
			setFunc = GroupBuffsMenu.SetFrameIsPvpEnabled		
		},
		[16] = {
			type = "checkbox",
			name = GroupBuffs.config.constants.menu.ENABLED_IN_PVE,
			getFunc = GroupBuffsMenu.GetFrameIsPveEnabled,
			setFunc = GroupBuffsMenu.SetFrameIsPveEnabled		
		},
		[17] = {
			type = "dropdown",
			name = GroupBuffs.config.constants.menu.NAME_DISPLAY_TYPE,
			choices = GroupBuffsMenu.GetDisplayModes(),
			choicesValues = GroupBuffsMenu.GetDisplayModesValues(),
			getFunc = GroupBuffsMenu.GetDisplayMode,
			setFunc = GroupBuffsMenu.SetSelectedDisplayMode,
			reference = GroupBuffsMenu.constants.references.DROPDOWN_DISPLAY
		},
		[18] = {
			type = "dropdown",
			name = GroupBuffs.config.constants.menu.ROLE_TYPE,
			choices = GroupBuffsMenu.GetRoleModes(),
			choicesValues = GroupBuffsMenu.GetRoleModesValues(),
			getFunc = GroupBuffsMenu.GetRoleMode,
			setFunc = GroupBuffsMenu.SetSelectedRoleMode,
			reference = GroupBuffsMenu.constants.references.DROPDOWN_ROLES
		},
		[19] = {
			type = "slider",
			name = GroupBuffs.config.constants.menu.FRAME_BUFF_SPACING,
			tooltip = GroupBuffs.config.constants.menu.FRAME_BUFF_SPACING_TOOLTIP,
			min = 0,
			max = 50,
			step = 1,	--(optional)
			getFunc = GroupBuffsMenu.GetFrameBuffSpacing,
			setFunc = GroupBuffsMenu.SetFrameBuffSpacing,
			width = "full",	--or "half" (optional)
			default = 15,	--(optional)
		},
		[20] = {
			type = "colorpicker",
			name = GroupBuffs.config.constants.menu.BUFF_HEADER_COLOR,
			getFunc = GroupBuffsMenu.GetFrameHeaderColor,	--(alpha is optional)
			setFunc = GroupBuffsMenu.SetFrameHeaderColor,	--(alpha is optional)
			width = "full"
		},
		[21] = {
			type = "divider",
			width = "full"
		},
		[22] = {
			type = "description",
			title = nil,
			text = GroupBuffs.config.constants.menu.BUFFS,
			width = "full"
		},
		[23] = {
			type = "editbox",
			name = GroupBuffs.config.constants.menu.NEW_BUFF,
			tooltip = nil,
			getFunc = GroupBuffsMenu.GetNewBuffName,
			setFunc = GroupBuffsMenu.SetNewBuffName,
			isMultiline = false,
			width = "full",
			warning = nil,
			default = "",
		},
		[24] = {
			type = "button",
			name = GroupBuffs.config.constants.menu.ADD_BUFF,
			tooltip = GroupBuffs.config.constants.menu.ADD_BUFF_TOOLTIP,
			func = GroupBuffsMenu.AddBuff,
			width = "full"
		},
		[25] = {
			type = "description",
			title = nil,
			text = "",
			width = "full",
			reference = GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_ERROR
		},
		[26] = {
			type = "divider",
			width = "full"
		},
		[27] = {
			type = "description",
			title = nil,
			text = GroupBuffs.config.constants.menu.SELECT_BUFF_TOOLTIP,
			width = "full"
		},
		[28] = {
			type = "dropdown",
			name = GroupBuffs.config.constants.menu.BUFF,
			tooltip = GroupBuffs.config.constants.menu.BUFF_TOOLTIP,
			choices = GroupBuffsMenu.GetBuffNames(),
			getFunc = GroupBuffsMenu.GetBuffName,
			setFunc = GroupBuffsMenu.SetBuffName,
			reference = GroupBuffsMenu.constants.references.DROPDOWN_BUFF_NAMES
		},
		[29] = {
			type = "button",
			name = GroupBuffs.config.constants.menu.REMOVE_BUFF,
			func = GroupBuffsMenu.RemoveBuff,
			width = "full",
			warning = GroupBuffs.config.constants.menu.REMOVE_BUFF_WARNING
		},
		[30] = {
			type = "description",
			title = nil,
			text = GroupBuffs.config.constants.menu.BUFF_SETTINGS,
			width = "full"
		},
		[31] = {
			type = "slider",
			name = GroupBuffs.config.constants.menu.BUFF_COLUMN_SIZE,
			tooltip = GroupBuffs.config.constants.menu.BUFF_COLUMN_SIZE_TOOLTIP,
			min = 75,
			max = 250,
			step = 1,	--(optional)
			getFunc = GroupBuffsMenu.GetBuffColumnSize,
			setFunc = GroupBuffsMenu.SetBuffColumnSize,
			width = "full",	--or "half" (optional)
			default = 100,	--(optional)
		},
		[32] = {
			type = "dropdown",
			name = GroupBuffs.config.constants.menu.SORT_ORDER,
			tooltip = GroupBuffs.config.constants.menu.SORT_ORDER_TOOLTIP,
			choices = GroupBuffsMenu.GetOrderChoices(),
			choicesValues = GroupBuffsMenu.GetOrderChoicesValues(),
			getFunc = GroupBuffsMenu.GetOrder,
			setFunc = GroupBuffsMenu.SetOrder
		},
		[33] = {
			type = "checkbox",
			name = GroupBuffs.config.constants.menu.BUFF_ALWAYS_SHOW_NAME,
			tooltip = GroupBuffs.config.constants.menu.BUFF_ALWAYS_SHOW_NAME_TOOLTIP,
			getFunc = GroupBuffsMenu.GetAlwaysShowName,
			setFunc = GroupBuffsMenu.SetAlwaysShowName
		},
		[34] = {
			type = "checkbox",
			name = GroupBuffs.config.constants.menu.BUFF_SHOW_NAME,
			getFunc = GroupBuffsMenu.GetShowBuffName,
			setFunc = GroupBuffsMenu.SetShowBuffName		
		},
		[35] = {
			type = "checkbox",
			name = GroupBuffs.config.constants.menu.BUFF_SHOW_STACK,
			getFunc = GroupBuffsMenu.GetShowBuffStack,
			setFunc = GroupBuffsMenu.SetShowBuffStack		
		},
		[36] = {
			type = "checkbox",
			name = GroupBuffs.config.constants.menu.BUFF_SHOW_DIFFERENT_OFF_DEAD_COLOR,
			getFunc = GroupBuffsMenu.GetShowBuffSDifferentOffDeadColor,
			setFunc = GroupBuffsMenu.SetShowBuffSDifferentOffDeadColor		
		},
		[37] = {
			type = "colorpicker",
			name = GroupBuffs.config.constants.menu.BUFF_DIFFERENT_OFF_DEAD_COLOR,
			getFunc = GroupBuffsMenu.GetBuffDifferentOffDeadColor,
			setFunc = GroupBuffsMenu.SetBuffDifferentOffDeadColor,
			width = "full"
		},
		[38] = {
			type = "divider",
			width = "full"
		},
		[39] = {
			type = "dropdown",
			name = GroupBuffs.config.constants.menu.BUFF_EFFECT_ID,
			tooltip = GroupBuffs.config.constants.menu.BUFF_EFFECT_ID_TOOLTIP,
			choices = GroupBuffsMenu.GetBuffEffectIdChoices(),
			getFunc = GroupBuffsMenu.GetBuffEffectId,
			setFunc = GroupBuffsMenu.SetBuffEffectId,
			reference = GroupBuffsMenu.constants.references.DROPDOWN_BUFF_EFFECT_ID
		},
		[40] = {
			type = "button",
			name = GroupBuffs.config.constants.menu.ADD_BUFF_EFFECT,
			func = GroupBuffsMenu.AddBuffEffect,
			width = "full",
			tooltip = GroupBuffs.config.constants.menu.ADD_BUFF_EFFECT_TOOLTIP
		},
		[41] = {
			type = "button",
			name = GroupBuffs.config.constants.menu.REMOVE_BUFF_EFFECT,
			func = GroupBuffsMenu.RemoveBuffEffect,
			width = "full",
			warning = GroupBuffs.config.constants.menu.REMOVE_BUFF_EFFECT_TOOLTIP
		},
		[42] = {
			type = "description",
			title = nil,
			text = "",
			width = "full",
			reference = GroupBuffsMenu.constants.references.DESCRIPTION_NEW_BUFF_EFFECT_ERROR
		},
		[43] = {
			type = "colorpicker",
			name = GroupBuffs.config.constants.menu.BUFF_EFFECT_COLOR,
			getFunc = GroupBuffsMenu.GetBuffEffectColor,	--(alpha is optional)
			setFunc = GroupBuffsMenu.SetBuffEffectColor,	--(alpha is optional)
			width = "full"
		},
		[44] = {
			type = "colorpicker",
			name = GroupBuffs.config.constants.menu.BUFF_EFFECT_FONT_COLOR,
			getFunc = GroupBuffsMenu.GetBuffEffectFontColor,	--(alpha is optional)
			setFunc = GroupBuffsMenu.SetBuffEffectFontColor,	--(alpha is optional)
			width = "full"
		},
		[45] = {
			type = "dropdown",
			name = GroupBuffs.config.constants.menu.SELECT_BUFF_EFFECT,
			tooltip = GroupBuffs.config.constants.menu.SELECT_BUFF_EFFECT_TOOLTIP,
			scrollable = true,
			choices = GroupBuffsMenu.GetBuffEffectNames(),
			getFunc = GroupBuffsMenu.GetBuffEffectName,
			setFunc = GroupBuffsMenu.SetBuffEffectName
		},
		[46] = {
			type = "submenu",
			name = GroupBuffs.config.constants.menu.SUBMENU_EFFECTS_VISUALS,
			controls = {
				[1] = {
				type = "description",
				title = nil,
				text = GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_IN_SETTINGS,
				width = "full"
				},
				[2] = {
					type = "slider",
					name = GroupBuffs.config.constants.menu.VISUAL_EFFECTS_DURATION,
					tooltip = GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_IN_DURATION_TOOLTIP,
					min = 0,
					max = 10,
					step = 1,	--(optional)
					getFunc = GroupBuffsMenu.GetEffectFadeInDuration,
					setFunc = GroupBuffsMenu.SetEffectFadeInDuration,
					width = "full",	--or "half" (optional)
					default = 0,	--(optional)
				},
				[3] = {
					type = "colorpicker",
					name = GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_IN_COLOR,
					getFunc = GroupBuffsMenu.GetEffectFadeInColor,	--(alpha is optional)
					setFunc = GroupBuffsMenu.SetEffectFadeInColor,	--(alpha is optional)
					width = "full"
				},
				[4] = {
				type = "description",
				title = nil,
				text = GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_OUT_SETTINGS,
				width = "full"
				},
				[5] = {
					type = "slider",
					name = GroupBuffs.config.constants.menu.VISUAL_EFFECTS_DURATION,
					tooltip = GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_OUT_DURATION_TOOLTIP,
					min = 0,
					max = 10,
					step = 1,	--(optional)
					getFunc = GroupBuffsMenu.GetEffectFadeOutDuration,
					setFunc = GroupBuffsMenu.SetEffectFadeOutDuration,
					width = "full",	--or "half" (optional)
					default = 0,	--(optional)
				},
				[6] = {
					type = "colorpicker",
					name = GroupBuffs.config.constants.menu.VISUAL_EFFECTS_FADE_OUT_COLOR,
					getFunc = GroupBuffsMenu.GetEffectFadeOutColor,	--(alpha is optional)
					setFunc = GroupBuffsMenu.SetEffectFadeOutColor,	--(alpha is optional)
					width = "full"
				},
			}
		},
		[47] = {
			type = "submenu",
			name = GroupBuffs.config.constants.menu.SUBMENU_EFFECTS_AUDIO,
			controls = {
				[1] = {
					type = "checkbox",
					name = GroupBuffs.config.constants.menu.AUDIO_EFFECTS_ACTIVE_SOUND,
					getFunc = GroupBuffsMenu.GetActiveSoundEffect,
					setFunc = GroupBuffsMenu.SetActiveSoundEffect		
				},
				[2] = {
					type = "slider",
					name = GroupBuffs.config.constants.menu.AUDIO_EFFECTS_INTERVAL,
					tooltip = GroupBuffs.config.constants.menu.AUDIO_EFFECTS_INTERVAL_TOOLTIP,
					min = 0,
					max = 25,
					step = 1,	--(optional)
					getFunc = GroupBuffsMenu.GetEffectAudioInterval,
					setFunc = GroupBuffsMenu.SetEffectAudioInterval,
					width = "full",	--or "half" (optional)
					default = 5,	--(optional)
				},
				[3] = {
					type = "dropdown",
					name = GroupBuffs.config.constants.menu.AUDIO_EFFECTS_AUDIO_EFFECT,
					tooltip = GroupBuffs.config.constants.menu.AUDIO_EFFECTS_AUDIO_EFFECT_TOOLTIP,
					choices = GroupBuffsMenu.GetAudioEffectNames(),
					choicesValues = GroupBuffsMenu.GetAudioEffectValues(),
					getFunc = GroupBuffsMenu.GetAudioEffectName,
					setFunc = GroupBuffsMenu.SetAudioEffectName,
					sort = "name-up",
					scrollable = true,
				}
			}
		}
	}
end
