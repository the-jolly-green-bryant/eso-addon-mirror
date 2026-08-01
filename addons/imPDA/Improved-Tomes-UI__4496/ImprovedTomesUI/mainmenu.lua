local MainMenu = {}
local MM = MAIN_MENU_KEYBOARD

function MainMenu:AddCategory(categoryInfo)
	local i = #ZO_CATEGORY_LAYOUT_INFO + 1
    categoryInfo.descriptor = i
	ZO_CATEGORY_LAYOUT_INFO[i] = categoryInfo

	categoryInfo.callback = function() MM:OnCategoryClicked(i) end

	ZO_MenuBar_AddButton(MM.categoryBar, categoryInfo)

	local subcategoryBar = CreateControlFromVirtual('ZO_MainMenuSubcategoryBar', MM.control, 'ZO_MainMenuSubcategoryBar', i)
	subcategoryBar:SetAnchor(TOP, MM.categoryBar, BOTTOM, 0, 7)
	local subcategoryBarFragment = ZO_SimpleSceneFragment:New(subcategoryBar)

	MM:RefreshCategoryIndicators()

	MM.categoryInfo[i] = {
		barControls = {},
		subcategoryBar = subcategoryBar,
		subcategoryBarFragment = subcategoryBarFragment,
	}

	return i
end

function MainMenu:AddMenu(category, sceneGroupName, iconData)
	-- see MainMenu_Keyboard:AddSceneGroup
	local categoryInfo = MM.categoryInfo[category]

	local sceneGroup = SCENE_MANAGER:GetSceneGroup(sceneGroupName)
	sceneGroup:RegisterCallback('StateChange', function(_, newState)
        if newState == SCENE_GROUP_SHOWING then
            MM.sceneShowGroupName = sceneGroupName
            local nextScene = SCENE_MANAGER:GetNextScene():GetName()
            -- this update can be called before the scene itself is set to showing,
            -- so make sure to set the active scene here so we can update the scene group bar correctly
            sceneGroup:SetActiveScene(nextScene)
            MM:SetLastSceneGroupName(categoryInfo, sceneGroupName)
            MM:SetupSceneGroupBar(category, sceneGroupName)
        elseif newState == SCENE_GROUP_SHOWN then
            local sceneGroupBarTutorialTrigger = MM.sceneGroupInfo[sceneGroupName].sceneGroupBarTutorialTrigger
            if sceneGroupBarTutorialTrigger then
                TriggerTutorial(sceneGroupBarTutorialTrigger)
            end
        end
    end)

	for s = 1, sceneGroup:GetNumScenes() do
        local sceneName = sceneGroup:GetSceneName(s)
        MM:AddRawScene(sceneName, category, categoryInfo, sceneGroupName)
    end

	if not MM:HasLast(categoryInfo) then
        MM:SetLastSceneGroupName(categoryInfo, sceneGroupName)
    end

    local layoutInfo = ZO_CATEGORY_LAYOUT_INFO[category]

    local sceneGroupBarFragment = ZO_SimpleSceneFragment:New(MM.sceneGroupBar)
    if not layoutInfo.hideSceneGroupBar then
        for id = 1, #iconData do
            local sceneName = iconData[id].descriptor
            local scene = SCENE_MANAGER:GetScene(sceneName)
            if not iconData[id].hideSceneGroupBar then
                scene:AddFragment(sceneGroupBarFragment)
            end
        end
    end

    MM.sceneGroupInfo[sceneGroupName] = {
        menuBarIconData = iconData,
        category = category,
        sceneGroupPreferredSceneFunction = nil,
        sceneGroupBarFragment = sceneGroupBarFragment,
        sceneGroupBarTutorialTrigger = nil,
    }

	MM:UpdateCategories()
end

IMP_MAIN_MENU = MainMenu