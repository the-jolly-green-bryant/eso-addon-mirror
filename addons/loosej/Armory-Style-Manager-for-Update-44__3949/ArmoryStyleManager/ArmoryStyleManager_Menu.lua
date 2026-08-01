ASM_MENU.LAM2 = LibAddonMenu2

-- @TODO add grouping of custom skill styles.

ASM_MENU.PanelData =
{
	type = "panel",
	name = "Armory Style Manager",
	displayName = "Armory Style Manager",
	version = ArmoryStyleManager.version,
	registerForRefresh = true
}

ASM_MENU.OptionData = {
    {
        type = "header",
        name = "Group icons",
        width = "full"
    },
    {
        type = "checkbox",
        name = "Apparel",
        width = "full",
        getFunc = function() return ArmoryStyleManager:GetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_GROUP_APPAREL) end,
        setFunc = function(newValue) ArmoryStyleManager:SetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_GROUP_APPAREL, newValue) end,
        default = true,
    },
    {
        type = "description",
        text = "This will group the icons for Costume, Hat, Major Adornment and Minor Adornment together.\n",
        width = "full",	--or "half" (optional)
    },
    {
        type = "checkbox",
        name = "Body features",
        width = "full",
        getFunc = function() return ArmoryStyleManager:GetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_GROUP_BODY_FEATURES) end,
        setFunc = function(newValue) ArmoryStyleManager:SetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_GROUP_BODY_FEATURES, newValue) end,
        default = true,
    },
    {
        type = "description",
        text = "This will group the icons for Skin, Hair, Facial Hair / Horns, Face Markings and Body Markings together.\n",
        width = "full",	--or "half" (optional)
    },
    {
        type = "checkbox",
        name = "Animal Companions",
        width = "full",
        getFunc = function() return ArmoryStyleManager:GetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_GROUP_ANIMAL_COMPANIONS) end,
        setFunc = function(newValue) ArmoryStyleManager:SetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_GROUP_ANIMAL_COMPANIONS, newValue) end,
        default = true,
    },
    {
        type = "description",
        text = "This will group the icons for Mount and Pet together.\n",
        width = "full",	--or "half" (optional)
    },
    {
        type = "checkbox",
        name = "Customized actions",
        width = "full",
        getFunc = function() return ArmoryStyleManager:GetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_GROUP_CUSTOMIZED_ACTIONS) end,
        setFunc = function(newValue) ArmoryStyleManager:SetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_GROUP_CUSTOMIZED_ACTIONS, newValue) end,
        default = true,
    },
    {
        type = "description",
        text = "This will group the icons for Custom Recall and Custom Gathering Actions together.\n",
        width = "full",	--or "half" (optional)
    },
    {
        type = "header",
        name = "Display icons",
        width = "full"
    },
    {
        type = "description",
        text = "Select which items you want shown in the armory UI",
        width = "full",	--or "half" (optional)
    },
}

ASM_MENU.Init = function()
    if ASM_MENU.LAM2 then
        local newCheckbox

		-- guild tabard
        newCheckbox = {
                type = "checkbox",
                name = "Guild Tabard",
                width = "full",
                getFunc = function() return ArmoryStyleManager:GetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_TABARD) end,
                setFunc = function(newValue) ArmoryStyleManager:SetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_TABARD, newValue) end,
                default = true,
            }

        table.insert(ASM_MENU.OptionData, newCheckbox)

        -- "regular" collectibles
        for _, collectibleCategoryType in pairs(ArmoryStyleManager:GetCollectibleTypes()) do
            newCheckbox = {
                    type = "checkbox",
                    name = GetString("SI_COLLECTIBLECATEGORYTYPE", collectibleCategoryType),
                    width = "full",
                    getFunc = function() return ArmoryStyleManager:GetDisplaySetting(collectibleCategoryType) end,
                    setFunc = function(newValue) ArmoryStyleManager:SetDisplaySetting(collectibleCategoryType, newValue) end,
                    default = true,
                }

            table.insert(ASM_MENU.OptionData, newCheckbox)
        end

        -- customized action - recall
        newCheckbox = {
                type = "checkbox",
                name = "Customized Recall",
                width = "full",
                getFunc = function() return ArmoryStyleManager:GetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_CUSTOM_RECALL) end,
                setFunc = function(newValue) ArmoryStyleManager:SetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_CUSTOM_RECALL, newValue) end,
                default = true,
            }

        table.insert(ASM_MENU.OptionData, newCheckbox)

        -- customized actions - gathering actions
        newCheckbox = {
                type = "checkbox",
                name = "Customized Gathering",
                width = "full",
                getFunc = function() return ArmoryStyleManager:GetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_CUSTOM_GATHERING) end,
                setFunc = function(newValue) ArmoryStyleManager:SetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_CUSTOM_GATHERING, newValue) end,
                default = true,
            }

        table.insert(ASM_MENU.OptionData, newCheckbox)

        -- skill styles
        newCheckbox = {
                type = "checkbox",
                name = "Skill Styles", -- @todo get localized string
                width = "full",
                getFunc = function() return ArmoryStyleManager:GetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_SKILL_STYLES) end,
                setFunc = function(newValue) ArmoryStyleManager:SetDisplaySetting(ArmoryStyleManager.DISPLAY_SETTING_SKILL_STYLES, newValue) end,
                default = true,
            }

        table.insert(ASM_MENU.OptionData, newCheckbox)

        ASM_MENU.LAM2:RegisterAddonPanel("ASM_SETTINGS", ASM_MENU.PanelData)
        ASM_MENU.LAM2:RegisterOptionControls("ASM_SETTINGS", ASM_MENU.OptionData)
    end
end
