local menu = MAIN_MENU_KEYBOARD
local category = MENU_CATEGORY_CONTACTS
local categoryInfo = menu.categoryInfo[category]
local sceneGroupName =  "contactsSceneGroup"

local function InjectContactsMenuTab(sceneName, categoryName, iconPathTemplate)
	local contactsSceneGroup = SCENE_MANAGER:GetSceneGroup(sceneGroupName)
	contactsSceneGroup:AddScene(sceneName)

	local iconData = {
		categoryName = categoryName,
		descriptor = sceneName,
		normal = iconPathTemplate:format("up"),
		pressed = iconPathTemplate:format("down"),
		highlight = iconPathTemplate:format("over"),
	}

	local scene = menu:AddRawScene(sceneName, category, categoryInfo, sceneGroupName)
	local sceneGroupBarFragment = ZO_FadeSceneFragment:New(menu.sceneGroupBar, nil, 0)
	scene:AddFragment(sceneGroupBarFragment)

	local menuBarIconData = menu.sceneGroupInfo[sceneGroupName].menuBarIconData
	menuBarIconData[#menuBarIconData + 1] = iconData
end
SocialIndicators.InjectContactsMenuTab = InjectContactsMenuTab
