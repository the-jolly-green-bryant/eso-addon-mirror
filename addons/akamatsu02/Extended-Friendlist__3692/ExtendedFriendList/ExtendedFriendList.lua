EFLAKA = {
	name = "ExtendedFriendList",
	UnitList = nil,
	savedVars = {
		friends = {}
	}
}

local UnitList = ZO_SortFilterList:Subclass()
local DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1)

UnitList.defaults = {}
UnitList.SORT_KEYS = {
	["name"] = {}
}

function UnitList:New()
	local units = ZO_SortFilterList.New(self, ExtendedFriendListMainWindow)
	return units
end

function UnitList:Initialize(control)
	ZO_SortFilterList.Initialize(self, control)

	self.sortHeaderGroup:SelectHeaderByKey("name")
	ZO_SortHeader_OnMouseExit(ExtendedFriendListMainWindowHeadersName)

	self.masterList = {}
	ZO_ScrollList_AddDataType(self.list, 1, "ExtendedFriendListUnitRow", 30, function(control, data) self:SetupUnitRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, UnitList.SORT_KEYS, self.currentSortOrder) end
	self:RefreshData()
end

function UnitList:BuildMasterList()
	self.masterList = {}
	local units = EFLAKA.savedVars.friends
	if units == nil then return end
	for k, v in pairs(units) do
		if v == true then
			table.insert(self.masterList, {
				["name"] = k
			})
		end
	end
end

function UnitList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	for i = 1, #self.masterList do
		local data = self.masterList[i]
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end

function UnitList:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end

function UnitList:SetupUnitRow(control, data)
	control.data = data
	control.name = GetControl(control, "Name")
	control.name:SetText(data.name)
	control.name.normalColor = DEFAULT_TEXT
	ZO_SortFilterList.SetupRow(self, control, data)
end

function UnitList:Refresh()
	self:RefreshData()
end

function EFLAKA.MouseEnter(control)
	EFLAKA.UnitList:Row_OnMouseEnter(control)
end

function EFLAKA.MouseExit(control)
	EFLAKA.UnitList:Row_OnMouseExit(control)
end

function EFLAKA.Whisper(control)
	local name = EFLAKA.GetNameFromControl(control)
	if name == "" then return end
	StartChatInput("", CHAT_CHANNEL_WHISPER, name)
end

function EFLAKA.Invite(control)
	local name = EFLAKA.GetNameFromControl(control)
	if name == "" then return end
	GroupInviteByName(name) 
end

function EFLAKA.FriendInvite(control)
	local name = EFLAKA.GetNameFromControl(control)
	if name == "" then return end
	RequestFriend(name, "Friends?") 
end

function EFLAKA.Mail(control)
	local name = EFLAKA.GetNameFromControl(control)
	if name == "" then return end
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(function()
		ZO_MailSendToField:SetText(name)
		ZO_MailSendSubjectField:SetText("")
		ZO_MailSendSubjectField:TakeFocus()
		ZO_MailSendBodyField:SetText("")
	end, 200)
end

function EFLAKA.Remove(control)
	local name = control.data.name
	EFLAKA.EditUnit(name, false)
end

function EFLAKA.TrackUnit(_, error)
	if error == SOCIAL_RESULT_ACCOUNT_TOO_MANY_FRIENDS then
		local targetName = GetUnitDisplayName("reticleover")
		ExtendedFriendListMainWindowAddNameInput:SetText(targetName)
		ExtendedFriendListMainWindow:SetHidden(false)
	end
end

function EFLAKA.AddUnitByNameInput()
	local name = ExtendedFriendListMainWindowAddNameInput:GetText()
	EFLAKA.EditUnit(name, true)
	ExtendedFriendListMainWindowAddNameInput:SetText("")
end

function EFLAKA.GetNameFromControl(control)
	local name = control.data.name
	if name == nil then return "" end
	if name == "" then return "" end
	return name
end

function EFLAKA.EditUnit(name, friend)
	if friend == nil then return end
	if name == nil then return end
	if name == "" then return end
	name = string.gsub(name, "@@", "@")
	EFLAKA.savedVars.friends[name] = friend
	EFLAKA.UnitList:Refresh()
end

function EFLAKA.ToggleUnit(name)
	local friend = true
	if name == nil then return end
	if name == "" then return end
	name = string.gsub(name, "@@", "@")
	if EFLAKA.savedVars.friends[name] == true then
		friend = false
		d(name.." removed.")
	else
		d(name.." added.")
	end
	EFLAKA.savedVars.friends[name] = friend
	EFLAKA.UnitList:Refresh()
end

function EFLAKA.SetElementAnchor()
	local position = EFLAKA.savedVars.position
    if position then
        local vara = position[1]
        local varb = position[2]
        local varc = position[3]
        local vard = position[4]
        local varf = position[5]
        local varg = CENTER
        if varc and vard and varf then
            vara = varc * GuiRoot:GetWidth()
            varb = vard * GuiRoot:GetHeight()
        else
            varf = TOPLEFT
            varg = TOPLEFT
        end
        ExtendedFriendListMainWindow:ClearAnchors()
        ExtendedFriendListMainWindow:SetAnchor(varg, GuiRoot, varf, vara, varb)
        if varg == TOPLEFT then
			EFLAKA.StorePosition()
        end
    end
end

function EFLAKA.StorePosition()
	if ExtendedFriendListMainWindow == nil then return end
    local vara, varb = ExtendedFriendListMainWindow:GetCenter()
    local varc, vard = GuiRoot:GetCenter()
    local varf, varg = GuiRoot:GetDimensions()
    local varh
    local vari
    local varj
    if vara > varc then
        vari = (vara-varf)/varf
        if varb > vard then
            varj = (varb-varg)/varg
            varh = BOTTOMRIGHT
        else
            varj = varb/varg
            varh = TOPRIGHT
        end
    else
        vari = vara/varf
        if varb > vard then
            varj = (varb-varg)/varg
            varh = BOTTOMLEFT
        else
            varj = varb/varg
            varh = TOPLEFT
        end
    end
	EFLAKA.savedVars.position = {ExtendedFriendListMainWindow:GetLeft(), ExtendedFriendListMainWindow:GetTop(), vari, varj, varh}
end

SLASH_COMMANDS["/efl"] = function(name) 
	if name ~= nil and name ~= "" then
		EFLAKA.ToggleUnit(name)
	end
	ExtendedFriendListMainWindow:SetHidden(false)
end

local function linkContextRightClick(_, button, _, _, linkType, name)
    if button == MOUSE_BUTTON_INDEX_RIGHT and (linkType == DISPLAY_NAME_LINK_TYPE or linkType == CHARACTER_LINK_TYPE) then
		zo_callLater(function()
		    AddCustomMenuItem(EFLAKA.name.." add", function() 
				if name ~= nil and name ~= "" then
					if linkType == DISPLAY_NAME_LINK_TYPE then
						name = "@"..name
					end
					EFLAKA.ToggleUnit(name)
				end
				ExtendedFriendListMainWindow:SetHidden(false)
			end, MENU_ADD_OPTION_LABEL)
			ShowMenu()
		end, 50)
	end
end

function EFLAKA.Init(_, addOnName)
	if addOnName ~= EFLAKA.name then return end
	
	EFLAKA.savedVars = ZO_SavedVars:NewAccountWide("EFLSavedVars", 1, nil, {
		["friends"] = {}
	})
	
	EVENT_MANAGER:RegisterForEvent(EFLAKA.name.."trackfullfl", EVENT_SOCIAL_ERROR, EFLAKA.TrackUnit)
	
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, linkContextRightClick)
	
	local scene = SCENE_MANAGER:GetScene("friendsList")
    if scene then
        scene:RegisterCallback("StateChange", function(oldState, newState)
			if (newState == SCENE_SHOWN) then
				ExtendedFriendListMainWindow:SetHidden(false)
			elseif (newState == SCENE_HIDDEN) then
				ExtendedFriendListMainWindow:SetHidden(true)
			end
        end)
    end

	EFLAKA.UnitList = UnitList:New()
	EFLAKA.UnitList:Refresh()
	
	EFLAKA.SetElementAnchor()
end

EVENT_MANAGER:RegisterForEvent("EFLAKA_Init", EVENT_ADD_ON_LOADED , EFLAKA.Init)