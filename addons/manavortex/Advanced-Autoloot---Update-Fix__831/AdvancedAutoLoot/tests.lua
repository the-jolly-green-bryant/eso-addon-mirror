MENU_CATEGORY_ADVANCEDAUTOLOOTMAILS = 13
local catDescriptor = 
    {
        binding = "TOGGLE_ADVANCEDAUTOLOOTMAILS",
        categoryName = "Advanced AutoLoot mail panel",

        descriptor = MENU_CATEGORY_ADVANCEDAUTOLOOTMAILS,
		normal = "AdvancedAutoLoot/Textures/mail_all_up.dds",
		pressed = "AdvancedAutoLoot/Textures/mail_all_down.dds",
		disabled = "EsoUI/Art/MainMenu/menuBar_mail_disabled.dds", 
		highlight = "EsoUI/Art/Mail/mail_tabIcon_inbox_over.dds",
    }
do
    local iconData = {
        {
            categoryName = "Send Metal panel",
            descriptor = "MailConfigPanel",
            normal = "AdvancedAutoLoot/Textures/mail_metal_up.dds",
            pressed = "AdvancedAutoLoot/Textures/mail_metal_down.dds",
            highlight = "EsoUI/Art/Mail/mail_tabIcon_inbox_over.dds",
        },
    }
	-- Have to add the main menu category myself (not part of the default init)
		local categoryLayoutInfo = catDescriptor
        categoryLayoutInfo.callback = function() MAIN_MENU:OnCategoryClicked(MENU_CATEGORY_ADVANCEDAUTOLOOTMAILS) end
        ZO_MenuBar_AddButton(MAIN_MENU.categoryBar, categoryLayoutInfo)

        local subcategoryBar = CreateControlFromVirtual("ZO_MainMenuSubcategoryBar", MAIN_MENU.control, "ZO_MainMenuSubcategoryBar", i)
        subcategoryBar:SetAnchor(TOP, MAIN_MENU.categoryBar, BOTTOM, 0, 7)
        local subcategoryBarFragment = ZO_FadeSceneFragment:New(subcategoryBar)
        MAIN_MENU.categoryInfo[MENU_CATEGORY_ADVANCEDAUTOLOOTMAILS] =
        {
            barControls = {},
            subcategoryBar = subcategoryBar,
            subcategoryBarFragment = subcategoryBarFragment,
        }
	
	
	
    SCENE_MANAGER:AddGroup("advancedLootMailSceneGroup", ZO_SceneGroup:New("MailConfigPanel"))
    MAIN_MENU:AddSceneGroup(MENU_CATEGORY_ADVANCEDAUTOLOOTMAILS, "advancedLootMailSceneGroup", iconData)
end