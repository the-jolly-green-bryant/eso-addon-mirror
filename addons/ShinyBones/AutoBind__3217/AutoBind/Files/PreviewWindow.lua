local _windowControl
local _listControl
local _bindButton

local _dataList
local _fragment

local _eventNameInventorySlotUpdate = AutoBind.AddonName .. "_Window_InventorySlotUpdate"
local _eventNameUpdate = AutoBind.AddonName .. "_Preview_Update"

local _isShown = false
local _isListDirty = true
local _itemList
local _tempTargetList = {}

local function UpdateBindButton(text, isEnabled)
	_bindButton:SetText(text)
	_bindButton:SetEnabled(isEnabled)
end

local function IsDataSelected(data)
	return data.Index == _tempTargetList[data.SetId][data.ItemType]
end

local function Show()
	if _isShown == true then return end
	_isShown = true

	HUD_SCENE:AddFragment(_fragment)
	HUD_UI_SCENE:AddFragment(_fragment)

	if SCENE_MANAGER:IsInUIMode() == false then
		SCENE_MANAGER:OnToggleHUDUIBinding()
	end

	_fragment:Show()
end
AutoBind.PreviewWindow.Show = Show

local function Hide()
	if _isShown == false then return end
	_isShown = false

	HUD_SCENE:RemoveFragment(_fragment)
	HUD_UI_SCENE:RemoveFragment(_fragment)

	_fragment:Hide()
end
AutoBind.PreviewWindow.Hide = Hide

function AutoBind.PreviewWindow.ToggleShown()
	if _isShown == false then
		Show()
	else
		Hide()
	end
end

local function UpdateList(itemList)
	local hasAny = false

	ZO_ScrollList_Clear(_listControl)

	for setId, itemTypes in pairs(itemList) do
		hasAny = true

		if _tempTargetList[setId] == nil then _tempTargetList[setId] = {} end

		for itemType, items in pairs(itemTypes) do
			if _tempTargetList[setId][itemType] == nil or _tempTargetList[setId][itemType] > #items then
				_tempTargetList[setId][itemType] = 1
			end

			AutoBind.SortItemsByQuality(items)

			for i, item in ipairs(items) do
				item.Index = i
				table.insert(_dataList, ZO_ScrollList_CreateDataEntry(1, item, 1))
			end
		end
	end

	ZO_ScrollList_Commit(_listControl, _dataList)
	_itemList = itemList
	_isListDirty = false

	if hasAny == true then
		UpdateBindButton(GetString(SI_SBAUTOBIND_PREVIEW_BIND), true)
	else
		UpdateBindButton(GetString(SI_SBAUTOBIND_PREVIEW_NO_ITEMS_FOUND), false)
	end
end

local function SetBindTarget(data)
	if _tempTargetList[data.SetId][data.ItemType] == data.Index then
		_tempTargetList[data.SetId][data.ItemType] = 0
	else
		_tempTargetList[data.SetId][data.ItemType] = data.Index
	end

	ZO_ScrollList_RefreshVisible(_listControl)
end

local function SetupCallback(control, data)
	local button = control:GetNamedChild("_LinkButton")

	button:SetText(data.ItemLink)
	button:SetHandler("OnClicked", function() SetBindTarget(data) end)

	control:GetNamedChild("_IsTargetTexture"):SetHidden(not IsDataSelected(data))
end

local function BindButtonClick()
	local boundCount = 0

	for setId, itemTypes in pairs(_itemList) do
		for itemType, items in pairs(itemTypes) do
			local targetIndex = _tempTargetList[setId][itemType]

			if targetIndex > 0 then
				items[targetIndex].Bind()
				boundCount = boundCount + 1
			end
		end
	end

	if boundCount > 0 then
		AutoBind.ThrowAlertItemsBound(boundCount)
	end

	Hide()
end

local function Refresh()
	if _isListDirty == false then return end

	local scrollValue = ZO_ScrollList_GetScrollValue(_listControl)

	UpdateList(AutoBind.GetUnknownItems(BAG_BACKPACK))

	if scrollValue > 0 then
		ZO_ScrollList_ScrollAbsolute(_listControl, scrollValue)
	end
end

local function OnShow()
	local function SetListDirty()
		UpdateBindButton(GetString(SI_SBAUTOBIND_PREVIEW_REFRESHING), false)
		_isListDirty = true
	end

	EVENT_MANAGER:RegisterForEvent(_eventNameInventorySlotUpdate, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SetListDirty)
	EVENT_MANAGER:AddFilterForEvent(_eventNameInventorySlotUpdate, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)

	EVENT_MANAGER:RegisterForUpdate(_eventNameUpdate, 500, Refresh)

	Refresh()
end

local function OnHide()
	ZO_ScrollList_Clear(_listControl)
	ZO_ScrollList_Commit(_listControl, _dataList)

	EVENT_MANAGER:UnregisterForEvent(_eventNameInventorySlotUpdate, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	EVENT_MANAGER:UnregisterForUpdate(_eventNameUpdate)

	_isListDirty = true
	_itemList = nil
	_tempTargetList = {}
end

function AutoBind.PreviewWindow.Initialize()
	_windowControl = SbAutoBind_PreviewWindowControl
	_windowControl:GetNamedChild("_HeaderLabel"):SetText(zo_strformat("<<1>> - <<2>>", AutoBind.AddonName, GetString(SI_SBAUTOBIND_PREVIEW_HEADER)))

	_fragment = ZO_SimpleSceneFragment:New(_windowControl)

	_listControl = _windowControl:GetNamedChild("_List")
	ZO_ScrollList_AddDataType(_listControl, 1, "SbAutoBind_ListItemTemplate", 25, SetupCallback)
	_dataList = ZO_ScrollList_GetDataList(_listControl)

	_windowControl:SetHandler("OnShow", OnShow)
	_windowControl:SetHandler("OnHide", OnHide)

	_bindButton = _windowControl:GetNamedChild("_BindButton")
	_bindButton:SetHandler("OnClicked", BindButtonClick)

	_windowControl:GetNamedChild("_CancelButton"):SetHandler("OnClicked", Hide)
end
