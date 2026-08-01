-- RIGHT_PANEL_BG_EMPTY_WORLD_ITEM_PREVIEW_OPTIONS_FRAGMENT = ZO_ItemPreviewOptionsFragment:New({
    -- paddingLeft = 0,
    -- paddingRight = 550,
    -- dynamicFramingConsumedWidth = 550,
    -- dynamicFramingConsumedHeight = 300,
    -- previewInEmptyWorld = true,
    -- forcePreparePreview = false,
-- })

-- local function CalculateWindowTarget()
	-- local x = zo_lerp(0, ZO_SharedRightPanelBackground:GetLeft(), .5)
	-- local y = zo_lerp(0, ZO_KeybindStripMungeBackgroundTexture:GetTop(), .55)
	-- return x, y
-- end

-- function ZO_NormalizedPointFragment:New(normalizedPointCallback, executeCallback)
    -- local fragment = ZO_SceneFragment.New(self)
    -- fragment.eventNamespace = "ZO_FramePlayerTargetFragment"..self.id
    -- self.id = self.id + 1

    -- function fragment.UpdateTarget()
        -- local x, y = normalizedPointCallback()
        -- local normalizedX, normalizedY = NormalizeUICanvasPoint(x, y)
        -- executeCallback(normalizedX, normalizedY)
    -- end

    -- return fragment
-- end

-- FRAME_TARGET_WINDOW_FRAGMENT = ZO_NormalizedPointFragment:New(CalculateWindowTarget, SetFrameLocalPlayerTarget)


----------------------------------------------------------------------------------------------------------------------------------------------------------------


local ADDON_NAME			= "Custom Item Preview(Furniture)"
-- local ADDON_VERSION		= GetAddOnVersion(addOnIndex) –- version.
-- local ADDON_DIRECTORY	= GetAddOnRootDirectoryPath(addOnIndex) –- directoryPath.
local ADDON_AUTHOR			= "@KL1SK"
local ADDON_WEBSITE			= "https://www.esoui.com/downloads/info2562-CustomItemPreviewFurniture.html#comments"

CustomItemPreview = {
	customPreview = 'nil',
	angle = {
		interactionsScenes	= {},
		inventory			= {},
	},
}

local CIP			= CustomItemPreview
local IP			= SYSTEMS:GetObject("itemPreview")
local ignore_name	= GetString(SI_ITEM_ACTION_PREVIEW)

local keybindButtonGroups = {
	'houseBankWithdrawTabKeybindButtonGroup',
	'houseBankDepositTabKeybindButtonGroup',
	'bankWithdrawTabKeybindButtonGroup',
	'bankDepositTabKeybindButtonGroup',
	'guildBankWithdrawTabKeybindButtonGroup',
	'guildBankDepositTabKeybindButtonGroup',
}

local keybindButton = {
		name		= GetString(SI_PREVIEW_CLEAR_INVENTORY_PREVIEW),
		keybind		= 'UI_SHORTCUT_NEGATIVE',
		visible		= IsCurrentlyPreviewing,
		callback	= function() IP:EndCurrentPreview() end,
}

for i = 1, #keybindButtonGroups do
	table.insert(PLAYER_INVENTORY[keybindButtonGroups[i]], keybindButton)
end

CIP.interactionsScenes = {
	['bank']				= true,
	['houseBank']			= true,
	['guildBank']			= true,
	-- ['store']				= true,
}

CIP.blurFragments = {
	FRAME_TARGET_BLUR_CENTERED_FRAGMENT,
	FRAME_TARGET_STANDARD_RIGHT_PANEL_MEDIUM_LEFT_PANEL_FRAGMENT,
	FRAME_INTERACTION_STANDARD_RIGHT_PANEL_MEDIUM_LEFT_PANEL_FRAGMENT,
	FRAME_TARGET_BLUR_STANDARD_RIGHT_PANEL_MEDIUM_LEFT_PANEL_FRAGMENT,
}

function CIP:UpdateBlurFragments(show)
	if CIP.currentScene:GetState() ~= "shown" then return end

	local blurFragments	= self.blurFragments
	for i = 1, #blurFragments do
		if self.currentScene:HasFragment(blurFragments[i]) then
			if show then
				blurFragments[i]:Show()
			else
				blurFragments[i]:Hide()
			end
		end
	end
end

function CIP:ToggleInteractionCameraPreview()
    if not IsCurrentlyPreviewing() then
		SetInteractionUsingInteractCamera(false)
		SCENE_MANAGER:AddFragment(FRAME_TARGET_STORE_WINDOW_FRAGMENT)
		SCENE_MANAGER:AddFragment(FRAME_PLAYER_ON_SCENE_HIDDEN_FRAGMENT)
		SCENE_MANAGER:AddFragment(RIGHT_PANEL_BG_EMPTY_WORLD_ITEM_PREVIEW_OPTIONS_FRAGMENT)
		SCENE_MANAGER:AddFragment(IP.fragment)
	else
		SCENE_MANAGER:RemoveFragmentImmediately(IP.fragment)
		SCENE_MANAGER:RemoveFragment(RIGHT_PANEL_BG_EMPTY_WORLD_ITEM_PREVIEW_OPTIONS_FRAGMENT)
		SCENE_MANAGER:RemoveFragmentImmediately(FRAME_PLAYER_ON_SCENE_HIDDEN_FRAGMENT)
		SCENE_MANAGER:RemoveFragment(FRAME_TARGET_STORE_WINDOW_FRAGMENT)
		SetInteractionUsingInteractCamera(true)
	end
end

ZO_PreHook(IP, "EndCurrentPreview", function(...)
	if CIP.customPreview == 'inventory' and not CIP.isSpin then
		CIP.currentScene:RemoveFragment(FRAME_PLAYER_FRAGMENT)
	elseif CIP.interactionsScenes[CIP.customPreview] then
		CIP:ToggleInteractionCameraPreview()
		KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
	end
	
	if CIP.customPreview ~= 'nil' then
		CIP:UpdateBlurFragments(true)
		CIP.customPreview = 'nil'
	end
end)

ZO_PreHook(IP, 'PreviewInventoryItem', function(self, bagId, slotIndex)
	local currentScene	= SCENE_MANAGER.currentScene
	CIP.currentScene	= currentScene
	if not IsCurrentlyPreviewing() then
		if currentScene.name == 'inventory' then
			CIP.isSpin = currentScene:HasFragment(FRAME_PLAYER_FRAGMENT)

			CIP.customPreview = 'inventory'

			if not CIP.isSpin then
				currentScene:AddFragment(FRAME_PLAYER_FRAGMENT)
			end
		end
		CIP:UpdateBlurFragments(false)
	end
end)

ZO_PreHook(ZO_InventorySlotActions, 'Show', function(self)
	if self.m_contextMenuMode then
		local inventorySlot		= self.m_inventorySlot
		local bagId, slotIndex	= inventorySlot.bagId, inventorySlot.slotIndex
		local currentScene_name	= SCENE_MANAGER.currentScene.name

		if CIP.interactionsScenes[currentScene_name] and CanInventoryItemBePreviewed(bagId, slotIndex) then
			local keybindActions = self.m_keybindActions[1]
			if keybindActions and keybindActions[1] == ignore_name then
				--
			else
				self:AddSlotAction(SI_ITEM_ACTION_PREVIEW, function()
					if not IsCurrentlyPreviewing() then
						CIP.customPreview = currentScene_name
						CIP:ToggleInteractionCameraPreview()
					end
					IP:PreviewInventoryItem(bagId, slotIndex)
					KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
				end, nil)
			end
		end
	end
end)

-- function CIP:SetAngle(delta)
	-- local options	= self.optionsScenes[self.currentScene.name] or self.optionsScenes["shared"]
	-- local x, y		= options.x, options.y

	-- y = y - delta * .1
	-- if y > .9 then
		-- y = .9
	-- elseif y < 0 then
		-- y = 0
	-- end

	-- options.y = y


	-- if self.currentScene.name == 'inventory' then
		-- SetFrameLocalPlayerTarget(x, y)
	-- else
		-- local x = zo_lerp(0, ZO_SharedRightPanelBackground:GetLeft(), .5)
		-- local y = zo_lerp(0, ZO_KeybindStripMungeBackgroundTexture:GetTop(), delta or .55)
		-- SetFrameLocalPlayerTarget(NormalizeUICanvasPoint(x,y))
	-- end
-- end

-- ZO_PreHookHandler(IP.rotationControl, "OnMouseWheel", function(self, delta)
	-- if CIP.customPreview then
		-- CIP:SetAngle(delta)
	-- end
-- end)