
local Kela_Undaunted = ZO_Gamepad_ParametricList_Screen:Subclass()

function Kela_Undaunted:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function Kela_Undaunted:Initialize(control)
    KELA_UNDAUNTED_SCENE = ZO_Scene:New("kelaUndaunted", SCENE_MANAGER)
	
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, nil, KELA_UNDAUNTED_SCENE)

    local kelaUndauntedFragment = ZO_FadeSceneFragment:New(control)
    KELA_UNDAUNTED_SCENE:AddFragment(kelaUndauntedFragment)

    self.headerData = {
        titleText = GetString(KELA_MAINMENU_UNDAUNTED),
    }

    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    local list = self:GetMainList()
    list:SetHandleDynamicViewProperties(true)


end

function Kela_Undaunted:InitializeKeybindStripDescriptors()
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



    function Kela_Undaunted:PopulateList()
        local list = self:GetMainList()
        list:Clear()
		
		AddEntry(list, KELA_MAINMENU_UNDAUNTED_TODAY, nil, "EsoUI/Art/Notifications/Gamepad/gp_notification_cs.dds", "helpCustomerServiceGamepad")
        AddEntry(list, KELA_MAINMENU_UNDAUNTED_DROPDOWN, KELA_MAINMENU_UNDAUNTED_PLEDGES, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_tutorial.dds", "helpTutorialsCategoriesGamepad")
        
		list:Commit()
    end
end

function Kela_Undaunted:PerformUpdate()
    self:PopulateList()

    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
 
    self.headerData.titleText = GetString(KELA_MAINMENU_UNDAUNTED)
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    self.dirty = false
end

-- XML Functions

function Kela_Undaunted_OnInitialize(control)
    KELA_UNDAUNTED = Kela_Undaunted:New(control)
	SYSTEMS:RegisterGamepadObject(KELA_UNDAUNTED, self)
end