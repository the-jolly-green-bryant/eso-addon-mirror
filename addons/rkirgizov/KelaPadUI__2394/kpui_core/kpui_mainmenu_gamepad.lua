
local Kela_Gamepad_Root = ZO_Gamepad_ParametricList_Screen:Subclass()

function Kela_Gamepad_Root:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function Kela_Gamepad_Root:Initialize(control)
    KELA_ROOT_GAMEPAD_SCENE = ZO_Scene:New("kelaRootGamepad", SCENE_MANAGER)
	
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, nil, KELA_ROOT_GAMEPAD_SCENE)

    local kelaRootFragment = ZO_FadeSceneFragment:New(control)
    KELA_ROOT_GAMEPAD_SCENE:AddFragment(kelaRootFragment)

    self.headerData = {
        titleText = GetString(KELA_MAINMENU_TITLE),
        messageText = GetString(KELA_MAINMENU_HEADER),
    }

    local headerMessageControl = control:GetNamedChild("Mask"):GetNamedChild("Container"):GetNamedChild("HeaderContainer"):GetNamedChild("Header"):GetNamedChild("Message")
    headerMessageControl:SetFont("ZoFontGamepadCondensed42")

    local websiteText = CreateControlFromVirtual("$(parent)HelpWebsite", control, "ZO_Gamepad_HelpWebsiteTemplate")
    websiteText:SetParent(self.header)
    local websiteAnchor = ZO_Anchor:New(TOP, headerMessageControl, BOTTOM, 0, 55)
    websiteAnchor:AddToControl(websiteText)
    
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    local list = self:GetMainList()
    list:SetHandleDynamicViewProperties(true)


end



function Kela_Gamepad_Root:InitializeKeybindStripDescriptors()
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

                    if targetData.isDialog then
                        ZO_Dialogs_ShowGamepadDialog(destinationName)
                    else
                        SCENE_MANAGER:Push(destinationName)
                    end
                end,
        },
    }

    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON)
    ZO_Gamepad_AddListTriggerKeybindDescriptors(self.keybindStripDescriptor, self:GetMainList())
end


local function AddEntryToList(list, entry, menuEntryToEntryIndex)
	local entryData = entry.data

	if not entryData.isVisibleCallback or entryData.isVisibleCallback() then
		local customTemplate = entryData.customTemplate
		local postPadding = entryData.postPadding or 0
		local entryTemplate = customTemplate and customTemplate or "ZO_GamepadNewMenuEntryTemplate"
   
		local showHeader = entryData.showHeader
		local useHeader = entry.header
		if type(showHeader) == "function" then
			useHeader = showHeader()
		elseif type(showHeader) == "boolean" then
			useHeader = showHeader
		end

		local name = entryData.name
		KelaPostMsg("name "..tostring(name))
		if type(name) == "function" then
			entry:SetText(name())
		end

		if useHeader then
			KelaPostMsg("useHeader")
			list:AddEntryWithHeader(entryTemplate, entry, 0, postPadding)
		else
			KelaPostMsg("NotUseHeader")
			list:AddEntry(entryTemplate, entry, 0, postPadding)
		end
		--menuEntryToEntryIndex[entry.id] = list:GetNumEntries()

		return true
	end
	return false
end


do
    local IS_DIALOG = true
    local IS_SCENE = false
    
    local function AddEntry(list, name, icon, destination, isDialog)
        local data = ZO_GamepadEntryData:New(GetString(name), icon)
        data:SetIconTintOnSelection(true)
        data.destination = destination
        data.isDialog = isDialog
        list:AddEntry("ZO_GamepadMenuEntryTemplate", data)
    end



    function Kela_Gamepad_Root:PopulateList()
        local list = self:GetMainList()
        list:Clear()


		for _, entry in ipairs(KELA_MENU_ENTRIES) do
			KelaPostMsg("222222222222")
			if AddEntryToList(list, entry, 1) then
				local entryData = entry.data
				KelaPostMsg("entryData.name "..tostring(entryData.name))
				AddEntry(list, entryData.name, "EsoUI/Art/Notifications/Gamepad/gp_notification_cs.dds", "helpCustomerServiceGamepad", IS_SCENE)
				-- currentMenuIndex = currentMenuIndex + 1
				-- if entry.data.scene == DEFAULT_MENU_ENTRY_SCENE_NAME then
					-- defaultEntryIndex = currentMenuIndex
				-- end
			end
		end

        AddEntry(list, SI_GAMEPAD_HELP_CUSTOMER_SERVICE, "EsoUI/Art/Notifications/Gamepad/gp_notification_cs.dds", "helpCustomerServiceGamepad", IS_SCENE)
        -- AddEntry(list, SI_HELP_TUTORIALS, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_tutorial.dds", "helpTutorialsCategoriesGamepad", IS_SCENE)
        -- AddEntry(list, SI_GAMEPAD_HELP_LEGAL_MENU, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_terms.dds", "helpLegalDocsGamepad", IS_SCENE)
        -- if IsSubmitFeedbackSupported() then
            -- AddEntry(list, SI_CUSTOMER_SERVICE_SUBMIT_FEEDBACK, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_submitFeedback.dds", "helpSubmitFeedbackGamepad", IS_SCENE)
        -- end
        -- AddEntry(list, SI_CUSTOMER_SERVICE_QUEST_ASSISTANCE, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_quests.dds", "helpQuestAssistanceGamepad", IS_SCENE)
        -- AddEntry(list, SI_CUSTOMER_SERVICE_ITEM_ASSISTANCE, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds", "helpItemAssistanceGamepad", IS_SCENE)
        
        list:Commit()
    end
end

function Kela_Gamepad_Root:PerformUpdate()
    self:PopulateList()

    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
 
    self.headerData.titleText = GetString(KELA_MAINMENU_TITLE)
    self.headerData.messageText = GetString(KELA_MAINMENU_HEADER)
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    self.dirty = false
end

-- XML Functions

function Kela_Gamepad_Root_OnInitialize(control)
    KELA_ROOT_GAMEPAD = Kela_Gamepad_Root:New(control)
	SYSTEMS:RegisterGamepadObject(KELA_ROOT_GAMEPAD, self)
end