
local Kela_QuickAccess = ZO_Gamepad_ParametricList_Screen:Subclass()

function Kela_QuickAccess:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function Kela_QuickAccess:Initialize(control)
    KELA_QUICKACCESS_SCENE = ZO_Scene:New("kelaQuickAccess", SCENE_MANAGER)
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, nil, KELA_QUICKACCESS_SCENE)

    local kelaQuickAccessFragment = ZO_FadeSceneFragment:New(control)
    KELA_QUICKACCESS_SCENE:AddFragment(kelaQuickAccessFragment)

    self.headerData = {
        titleText = GetString(KELA_MAINMENU_QUICKACCESS),
    }

    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    local list = self:GetMainList()
    list:SetHandleDynamicViewProperties(true)


end

function Kela_QuickAccess:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        -- Select
        {
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                    local targetData = self:GetMainList():GetTargetData()
                    local destination = targetData.destination
					SCENE_MANAGER:Push(destination)
					if destination == "gamepad_quest_journal" then 
						zo_callLater(function()
								QUEST_JOURNAL_GAMEPAD.questList:EnableAnimation(false)
								QUEST_JOURNAL_GAMEPAD.questList:SetSelectedDataByEval(function(data)
									if data then return data.questIndex == QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex() end
								end)
								QUEST_JOURNAL_GAMEPAD.questList:EnableAnimation(true)
						end, 100)
					end
                end,
        },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON)
    ZO_Gamepad_AddListTriggerKeybindDescriptors(self.keybindStripDescriptor, self:GetMainList())
end


do

    local function AddEntry(list, name, header, icon, destination)
        local data = ZO_GamepadEntryData:New(GetString(name), icon)
        data:SetIconTintOnSelection(true)
        data.destination = destination
        if header then
			data.header = GetString(header)
			list:AddEntryWithHeader("ZO_GamepadMenuEntryTemplate", data)
		else
			list:AddEntry("ZO_GamepadMenuEntryTemplate", data)
		end
    end

    function Kela_QuickAccess:PopulateList()
        local list = self:GetMainList()
        list:Clear()
		
		if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_QUICKACCESS_QUEST) then
			AddEntry(list, SI_GAMEPAD_MAIN_MENU_JOURNAL_QUESTS, nil, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_quests.dds", "gamepad_quest_journal")
        end
		if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_QUICKACCESS_MAIL) then
			AddEntry(list, SI_MAIN_MENU_MAIL, nil, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_mail.dds", "mailManagerGamepad")
		end
		
        if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_QUICKACCESS_GROUP) then
            AddEntry(list, SI_MAIN_MENU_GROUP, nil, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_groups.dds", "gamepad_groupList")
		end		
		
		list:Commit()
    end
end

function Kela_QuickAccess:PerformUpdate()
    self:PopulateList()

    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
 
    self.headerData.titleText = GetString(KELA_MAINMENU_QUICKACCESS)
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    self.dirty = false
end

function Kela_QuickAccess:OnShowing()
    ZO_Gamepad_ParametricList_Screen.OnShowing(self)
	self:PopulateList()
end

-- XML Functions

function Kela_QuickAccess_OnInitialize(control)
    KELA_QUICKACCESS = Kela_QuickAccess:New(control)
	SYSTEMS:RegisterGamepadObject(KELA_QUICKACCESS, self)
end