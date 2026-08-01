local Kela_Sets = ZO_Gamepad_ParametricList_Screen:Subclass()

function Kela_Sets:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function Kela_Sets:Initialize(control)
    KELA_SETS_SCENE = ZO_Scene:New("kelaSets", SCENE_MANAGER)
	
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, nil, KELA_SETS_SCENE)

    local kelaSetsFragment = ZO_FadeSceneFragment:New(control)
    KELA_SETS_SCENE:AddFragment(kelaSetsFragment)

    self.headerData = {
        titleText = GetString(KELA_MAINMENU_SETS),
    }

    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    local list = self:GetMainList()
    list:SetHandleDynamicViewProperties(true)


end

function Kela_Sets:InitializeKeybindStripDescriptors()
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
                    local destinationName = type(destination) == "function" and destination() or destination

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



    function Kela_Sets:PopulateList()
        local list = self:GetMainList()
        list:Clear()
		
		AddEntry(list, KELA_MAINMENU_SETS_COLLECTED, nil, "EsoUI/Art/Notifications/Gamepad/gp_notification_cs.dds", "helpCustomerServiceGamepad")
        AddEntry(list, KELA_MAINMENU_SETS_CRAFTING, KELA_MAINMENU_INFO, "EsoUI/Art/Notifications/Gamepad/gp_notification_cs.dds", "helpCustomerServiceGamepad")
        AddEntry(list, KELA_MAINMENU_SETS_LOCATIONS, nil, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_tutorial.dds", "helpTutorialsCategoriesGamepad")
        AddEntry(list, KELA_MAINMENU_SETS_DUNGEONS, nil, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_terms.dds", "helpLegalDocsGamepad")
		AddEntry(list, KELA_MAINMENU_SETS_MONSTERS, nil, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_quests.dds", "helpQuestAssistanceGamepad")
        
		list:Commit()
    end
end

function Kela_Sets:PerformUpdate()
    self:PopulateList()

    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
 
    self.headerData.titleText = GetString(KELA_MAINMENU_SETS)
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    self.dirty = false
end

-- XML Functions

function Kela_Sets_OnInitialize(control)
    KELA_SETS = Kela_Sets:New(control)
	SYSTEMS:RegisterGamepadObject(KELA_SETS, self)
end