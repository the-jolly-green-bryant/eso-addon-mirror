local SK = SwissKnife
local SKDS = SK.Data.scenesData
local SM = SCENE_MANAGER

local function RemoveFragment(scenes, fragmentToRemove)
	--local excludeScene
	--if fragmentToRemove == FRAME_PLAYER_FRAGMENT then excludeScene = "inventory" end
	for _, name in ipairs(scenes) do
		--if name ~= excludeScene then
		--	local scene = SM:GetScene(name)
		--	if scene:HasFragment(fragmentToRemove) then scene:RemoveFragment(fragmentToRemove) end
		--end
		local scene = SM:GetScene(name)
		if scene:HasFragment(fragmentToRemove) then scene:RemoveFragment(fragmentToRemove) end
	end
end

local function previewFix()
	-- preview fix
	local inventoryScene = SM:GetScene('inventory')
	local itemPreview = SYSTEMS:GetObject("itemPreview")
	local originPreviewInventoryItem = itemPreview.PreviewInventoryItem
	local originIsCharacterPreviewingAvailable = IsCharacterPreviewingAvailable

	local function callbackEndPreview()
		itemPreview:UnregisterCallback("EndCurrentPreview", callbackEndPreview)
		inventoryScene:RemoveFragment(FRAME_PLAYER_FRAGMENT)
	end

	local function newPreviewInventoryItem(...)
		inventoryScene:AddFragment(FRAME_PLAYER_FRAGMENT)
		itemPreview:RegisterCallback("EndCurrentPreview", callbackEndPreview)
		return originPreviewInventoryItem(...)
	end

	local function newIsCharacterPreviewingAvailable(...)
		return true
	end

	inventoryScene:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			IsCharacterPreviewingAvailable = newIsCharacterPreviewingAvailable
			itemPreview.PreviewInventoryItem = newPreviewInventoryItem
		elseif newState == SCENE_HIDDEN then
			IsCharacterPreviewingAvailable = originIsCharacterPreviewingAvailable
			itemPreview.PreviewInventoryItem = originPreviewInventoryItem
		end
	end)
end

local function InitScenesAnimationHook()
	if SK.savedVars.stopCameraRotate then
		for _, v in ipairs(SKDS.FRAGMENTS_TO_REMOVE) do
			RemoveFragment(SKDS.FRAME_PLAYER_FRAGMENT_SCENES, v)
		end
		if PP == nil then previewFix() end
	end
	local function InteractionsHook(self)
		if SK.savedVars.isDoNotInterruption then
			EndPendingInteraction()
			self:OnShown()
		    return true
		end
	end
	ZO_PreHook(END_IN_WORLD_INTERACTIONS_FRAGMENT, "Show", InteractionsHook)
end

-- Export
SK.Scenes = {
	InitScenesAnimationHook = InitScenesAnimationHook
}