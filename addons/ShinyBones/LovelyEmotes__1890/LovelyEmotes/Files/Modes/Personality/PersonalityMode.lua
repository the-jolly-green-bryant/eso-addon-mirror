LE_PersonalityListMode = LE_ModeBase:New("PersonalityList")

local _listControl
local _dataList

local _buttonTemplates = {
	"LE_EmoteTextButtonTemplate",
	"LE_EmoteDefaultButtonTemplate",
}

local function SetupList()
	ZO_ScrollList_Clear(_listControl)
	ZO_ScrollList_AddCategory(_listControl, 1)
	local personalities = LovelyEmotes.AvailablePersonalities

	for i, p in ipairs(personalities) do
		table.insert(_dataList, ZO_ScrollList_CreateDataEntry(1, p, 1))
	end

	table.sort(_dataList, function(firstValue, secondValue) return firstValue.data.Name < secondValue.data.Name end)
	ZO_ScrollList_Commit(_listControl, _dataList)
end

local function SetupCallback(control, data)
	if IsCollectibleActive(data.CollectibleId) then
		control:SetNormalFontColor(LOVELYEMOTES_COLOR_PERSONALITY_ACTIVE:UnpackRGBA())
	else
		control:SetNormalFontColor(ZO_NORMAL_TEXT:UnpackRGBA())
	end

	control:SetText(data.Name)
	control:SetHandler("OnClicked", function(control, button) UseCollectible(data.CollectibleId) end)
end

function LE_PersonalityListMode:Setup(parentControl)
	LE_ModeBase.Setup(self, parentControl)

	_listControl = CreateControlFromVirtual("LE_PersonalityScrollList", self.ContentControl, "ZO_ScrollList")
	_listControl:SetAnchor(TOPLEFT, self.ContentControl, TOPLEFT, 0, 0)
	_listControl:SetAnchor(BOTTOMRIGHT, self.ContentControl, BOTTOMRIGHT, 0, 0)

	ZO_ScrollList_AddDataType(_listControl, 1, _buttonTemplates[LovelyEmotes_Settings.SavedAccountVariables.EmoteListButtonDesign], 25, SetupCallback)
	_dataList = ZO_ScrollList_GetDataList(_listControl)
end

function LE_PersonalityListMode:GetHeight()
	local buttonsCount = #LovelyEmotes.AvailablePersonalities
	if buttonsCount > 14 then buttonsCount = 14 end

	return buttonsCount * 25
end

local function Callback_EmotesOverriddenUpdated()
	ZO_ScrollList_RefreshVisible(_listControl)
end

function LE_PersonalityListMode:Activate()
	LovelyEmotes_EventSystem.AddListener(LE_EVENT_EmotesOverriddenUpdated, Callback_EmotesOverriddenUpdated)
	LovelyEmotes_EventSystem.AddListener(LE_EVENT_AvailableEmotesUpdated, SetupList)

	SetupList()

	LE_ModeBase.Activate(self)
end

function LE_PersonalityListMode:Deactivate()
	LovelyEmotes_EventSystem.RemoveListener(LE_EVENT_EmotesOverriddenUpdated, Callback_EmotesOverriddenUpdated)
	LovelyEmotes_EventSystem.RemoveListener(LE_EVENT_AvailableEmotesUpdated, SetupList)

	LE_ModeBase.Deactivate(self)
end
