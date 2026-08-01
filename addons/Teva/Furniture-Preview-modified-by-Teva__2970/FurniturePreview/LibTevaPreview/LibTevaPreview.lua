-- LibTevaPreview based on LibPreview by Shinni
-- this library simplifies the preview of items

local LIB_NAME = "LibTevaPreview"
local VERSION = 18
LibTevaPreview = {}
local lib = LibTevaPreview
if not lib then return end

--
function lib:Debug(...)
	if lib.debugOutput then
		d(...)
	end
end--

function lib:Initialize()
	
	self.itemIdToMarkedId = {}
	
	self.defaultOptionsFragment = ZO_ItemPreviewOptionsFragment:New({
		paddingLeft = 0,
		paddingRight = 0,
		dynamicFramingConsumedWidth = 1050,
		dynamicFramingConsumedHeight = 300,
		maintainsPreviewCollection = true,
	})
	
	self.defaultLeftOptionsFragment = ZO_ItemPreviewOptionsFragment:New({
		paddingLeft = 0,
		paddingRight = 950,
		dynamicFramingConsumedWidth = 1150,
		dynamicFramingConsumedHeight = 300,
		maintainsPreviewCollection = true,
	})
	
	self.framePlayerFragment = ZO_FramePlayerFragment:New()
	self.framePlayerFragment:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_HIDING then
			DisablePreviewMode()	--self:DisablePreviewMode()
		end
	end)

	-- fragment which is added to the scene.
	-- when the scene changes, we know the preview is terminated
	self.externalPreviewExitFragment = ZO_SceneFragment:New()
	self.externalPreviewExitFragment:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_HIDING then
			self:DisablePreviewMode()
		end
	end)

	-- create a preview scene, which is used when we try to preview an item during the HUD or HUDUI scene
	--TevaNOTE: test commenting this section out
	self.scene = ZO_Scene:New(LIB_NAME, SCENE_MANAGER)
	self.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	self.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_CENTERED_NO_BLUR)

	if IsInGamepadPreferredMode() then
		self.scene:AddFragment(ITEM_PREVIEW_GAMEPAD:GetFragment())
	else
		self.scene:AddFragment(ITEM_PREVIEW_KEYBOARD:GetFragment())
	end

	self.scene:AddFragment(self.externalPreviewExitFragment)

	-- quaternary end preview keybind
	local function GetDescriptorFromButton(buttonOrEtherealDescriptor)
		if type(buttonOrEtherealDescriptor) == "userdata" then
			return buttonOrEtherealDescriptor.keybindButtonDescriptor
		end
		return buttonOrEtherealDescriptor
	end

	self.keybindButtonGroup = {
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
		{
			name =      GetString(SI_CRAFTING_EXIT_PREVIEW_MODE),
			keybind =   "UI_SHORTCUT_NEGATIVE",
			visible =   function()
								--d(IsCurrentlyPreviewing())
								return not self.keybindFragment:IsHidden()--IsCurrentlyPreviewing()--self.PreviewStartedByLibrary
						end,
			callback =  function()
							self:DisablePreviewMode()	--might break if remove self:
						end,
		}
	}

	self.keybindFragment = ZO_SceneFragment:New()
	self.keybindFragment:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWN then
			local descriptor = GetDescriptorFromButton(KEYBIND_STRIP.keybinds["UI_SHORTCUT_QUATERNARY"])
			if descriptor then
				KEYBIND_STRIP:RemoveKeybindButton(descriptor)
			end
			KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindButtonGroup)
			--
			if descriptor then
				if descriptor.keybindButtonGroupDescriptor then
					--local myDescriptor = GetDescriptorFromButton(KEYBIND_STRIP.keybinds["UI_SHORTCUT_QUATERNARY"])
					--d(descriptor.keybindButtonGroupDescriptor)
					for key, keybind in pairs(descriptor.keybindButtonGroupDescriptor) do
						if type(keybind) == "table" and keybind.keybind == "UI_SHORTCUT_QUATERNARY" then
							self.keybindFragment.originalKeybind = keybind
							self.keybindFragment.originalKey = key
							self.keybindFragment.originalGroup = descriptor.keybindButtonGroupDescriptor
							descriptor.keybindButtonGroupDescriptor[key] = nil--myDescriptor.keybindButtonGroupDescriptor[1]
							break
						end
					end
				end
			end--]]

		elseif newState == SCENE_HIDING then
			if self.keybindFragment.originalGroup then
				self.keybindFragment.originalGroup[self.keybindFragment.originalKey] = self.keybindFragment.originalKeybind
				self.keybindFragment.originalGroup = nil
				self.keybindFragment.originalKey = nil
				self.keybindFragment.originalKeybind = nil
			end
			KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindButtonGroup)
		end
	end )

	self.initialized = true
end

function lib:IsInitialized()
	return self.initialized
end

function lib:GetMarketIdFromItemLink(itemLink)
	-- if this is a recipe, preview the crafting result
	local resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
	if resultItemLink and resultItemLink ~= "" then
		itemLink = resultItemLink
	end
	
	if not IsItemLinkPlaceableFurniture(itemLink) then return end
	
	local _, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
	itemId = tonumber(itemId)
	
	local marketId = self.itemIdToMarkedId[ itemId ]
	if not marketId then return end
	
	if not CanPreviewMarketProduct(marketId) then return end
	
	return marketId
end

-- Returns true if the given itemLink can be previewed
function lib:CanPreviewItemLink(itemLink)
	return (self:GetMarketIdFromItemLink(itemLink) ~= nil)
end

local FRAME_PLAYER_ON_SCENE_HIDDEN_FRAGMENT = ZO_SceneFragment:New()
-- dummy frame fragment which doesn't do anything. this is used if there is already a frame fragment active
local NO_TARGET_CHANGE_FRAME = ZO_SceneFragment:New()

-- if we are already framing the player, we don't want to change the player location within the frame
-- with this little hack we can see if the framing is active already
lib.isFraming = false
ZO_PreHook("SetFrameLocalPlayerInGameCamera", function(value)
	lib.isFraming = value
end)

function lib:EnablePreviewMode(frameFragment, previewOptionsFragment)

	if self.previewStartedByLibrary then	--
		if self.keybindFragment:IsHidden() then
			self:Debug("re-add keybind")
			SCENE_MANAGER:AddFragment(self.keybindFragment)
		end--
		return
	end	
	self.previewStartedByLibrary = true		--TevaNOTE: needs to be true or cannot end preview, line was below next if statement previously
	
	--if IsCurrentlyPreviewing() then
	--	return
	--end
		
	-- select the correct frame position
	if not frameFragment then
		if SYSTEMS:IsShowing(ZO_TRADING_HOUSE_SYSTEM_NAME) or SYSTEMS:IsShowing("trade") then
			frameFragment = FRAME_TARGET_STANDARD_RIGHT_PANEL_FRAGMENT
			previewOptionsFragment = previewOptionsFragment or self.defaultLeftOptionsFragment
		elseif lib.isFraming then
			-- if the player is already framed (eg inventory) then don't change anything
			frameFragment = NO_TARGET_CHANGE_FRAME
		elseif HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing() then
			-- when showing the base scene, we can display the character in the center
			frameFragment = FRAME_TARGET_CENTERED_FRAGMENT
		elseif IsInteractionUsingInteractCamera() then
			frameFragment = FRAME_TARGET_CENTERED_FRAGMENT
		else
			-- otherwise use the slightly shifted to the left preview (most UI is on the right, so the preview should not be occluded)
			frameFragment = FRAME_TARGET_STANDARD_RIGHT_PANEL_FRAGMENT--FRAME_TARGET_CRAFTING_FRAGMENT
			previewOptionsFragment = previewOptionsFragment or self.defaultLeftOptionsFragment
		end
	end

	self.usedInteractionPreview = false
	self.addedPreviewFragment = false
-- --removing this if then else statement (leaving else active) fixes the trading posting, but breaks ending preview in inventory
	if not IsInteractionUsingInteractCamera() then	--try disabling part of this if section to fix trading house listing
		-- if we are in the base scene, trigger the preview scene
		if HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing() then
			self:Debug("enable preview scene")
			self.frameFragment = nil
			SCENE_MANAGER:Toggle(LIB_NAME)
			SCENE_MANAGER:AddFragment(previewOptionsFragment or self.defaultOptionsFragment)
			return
		end
		-- otherwise add preview to the currently viewed scene
		
		-- remember frame and options fragment so we can remove them when disabling the preview
		self.frameFragment = frameFragment
		self.previewOptionsFragment = previewOptionsFragment or self.defaultOptionsFragment
		
		SCENE_MANAGER:AddFragment(FRAME_PLAYER_ON_SCENE_HIDDEN_FRAGMENT)
		SCENE_MANAGER:AddFragment(self.frameFragment)
		SCENE_MANAGER:AddFragment(self.previewOptionsFragment)
--
		if IsInGamepadPreferredMode() then
			if not ITEM_PREVIEW_GAMEPAD:GetFragment():IsShowing() then
				SCENE_MANAGER:AddFragment(ITEM_PREVIEW_GAMEPAD:GetFragment())
				self.addedPreviewFragment = true
			end
		else
			if not ITEM_PREVIEW_KEYBOARD:GetFragment():IsShowing() then
				SCENE_MANAGER:AddFragment(ITEM_PREVIEW_KEYBOARD:GetFragment())
				self.addedPreviewFragment = true
			end
		end--

	else
		-- if we are interacting (eg trader or crafting) then use ZOS' the interaction preview system
		
		-- remember frame and options fragment so we can remove them when disabling the preview
		self.frameFragment = frameFragment
		self.previewOptionsFragment = previewOptionsFragment or self.defaultOptionsFragment
		self.usedInteractionPreview = true
		SYSTEMS:GetObject("itemPreview"):SetInteractionCameraPreviewEnabled(
			true,
			self.frameFragment,
			self.framePlayerFragment,
			self.previewOptionsFragment)
	end	--removing this if then else statement (leaving else active) fixes the trading posting, but breaks ending preview in inventory
	--
	if self.keybindFragment:IsHidden() then
		self:Debug("add keybind")
		SCENE_MANAGER:AddFragment(self.keybindFragment)
	end--
	
	SCENE_MANAGER:AddFragment(self.externalPreviewExitFragment)
	
end

function lib:DisablePreviewMode()
	if not self.previewStartedByLibrary then return end

	-- if preview via adding scene
--	if self.scene:IsShowing() then
--		SCENE_MANAGER:Show("hudui")
--		return
--	end--

	self.previewStartedByLibrary = false
	
	SCENE_MANAGER:RemoveFragment(self.externalPreviewExitFragment)
	-- if preview using ZOS' interaction preview
	if self.usedInteractionPreview then
		SYSTEMS:GetObject("itemPreview"):SetInteractionCameraPreviewEnabled(
			false,
			self.frameFragment,
			self.framePlayerFragment,
			self.previewOptionsFragment)
		SCENE_MANAGER:RemoveFragment(self.keybindFragment)
		return
	end--

	-- if preview via adding fragments; TevaNOTE: test commenting out all below to end of function
	--
	SCENE_MANAGER:RemoveFragment(FRAME_PLAYER_ON_SCENE_HIDDEN_FRAGMENT)
	SCENE_MANAGER:RemoveFragment(self.frameFragment)
	SCENE_MANAGER:RemoveFragment(self.previewOptionsFragment)
	if self.addedPreviewFragment then
		if IsInGamepadPreferredMode() then
			SCENE_MANAGER:RemoveFragment(ITEM_PREVIEW_GAMEPAD:GetFragment())
		else
			SCENE_MANAGER:RemoveFragment(ITEM_PREVIEW_KEYBOARD:GetFragment())
		end
	else--
		if IsInGamepadPreferredMode() then
			ITEM_PREVIEW_GAMEPAD:EndCurrentPreview()
		else
			ITEM_PREVIEW_KEYBOARD:EndCurrentPreview()
		end
	end
	SCENE_MANAGER:RemoveFragment(self.keybindFragment)--
--	DisablePreviewMode()
end

--[[function lib:PreviewItemLink(itemLink, frameFragment, optionsFragment)
	if not self.validHook then
	--	self:Debug("preview error: no valid hook created yet")
		return
	end
	self:EnablePreviewMode(frameFragment, optionsFragment)
	SYSTEMS:GetObject("itemPreview"):PreviewItemLink(itemLink)
end--]]

function lib:PreviewInventoryItemAsFurniture(bagId, slotIndex)
	if not self.validHook then
	--	self:Debug("preview error: no valid hook created yet")
		return
	end
	self:EnablePreviewMode()
	
	if IsInGamepadPreferredMode() then
--		ITEM_PREVIEW_GAMEPAD:PreviewInventoryItemAsFurniture(bagId, slotIndex)
		ITEM_PREVIEW_GAMEPAD:PreviewInventoryItem(bagId, slotIndex)
	else
--		ITEM_PREVIEW_KEYBOARD:PreviewInventoryItemAsFurniture(bagId, slotIndex)
		ITEM_PREVIEW_KEYBOARD:PreviewInventoryItem(bagId, slotIndex)
	end
end

local function OnActivated()
	EVENT_MANAGER:UnregisterForEvent(LIB_NAME, EVENT_PLAYER_ACTIVATED)
	
	lib:Initialize()
end

function lib:Load()
	EVENT_MANAGER:RegisterForEvent(LIB_NAME, EVENT_PLAYER_ACTIVATED, OnActivated)
	
	local previewStarted = false
	local untaintedFunction
	self.validHook = false
	HUD_SCENE:AddFragment(SYSTEMS:GetObject("itemPreview").fragment)
	lib.origOnPreviewShowing = ZO_ItemPreview_Shared.OnPreviewShowing
--	lib.log = {}

	ZO_PreHook(ZO_ItemPreview_Shared, "OnPreviewShowing", function()
		local success, msg = pcall(function() error("") end)
		local count = 0
		for start, endIndex in string.gfind(msg,"user:/AddOns") do
			count = count + 1
		end
		--d("num addon calls", count)
		--d(msg)
		if count ~= 3 then
			ZO_ERROR_FRAME:OnUIError(msg)
		--	self:Debug("FurniturePreview error. No valid hook")
			return
		end
		
		local origGetPreviewModeEnabled = GetPreviewModeEnabled
		GetPreviewModeEnabled = function()
			GetPreviewModeEnabled = origGetPreviewModeEnabled
			return true
		end
		
		ZO_ItemPreview_Shared.OnPreviewShowing = lib.origOnPreviewShowing
		lib.origRegisterForUpdate = EVENT_MANAGER.RegisterForUpdate
--
		ZO_PreHook(EVENT_MANAGER, "RegisterForUpdate", function(self, name, interval, func)
			if name == "ZO_ItemPreview_Shared" then
				local success, msg = pcall(function() error("") end)
				local count = 0
				for start, endIndex in string.gfind(msg,"user:/AddOns") do
					count = count + 1
				end
				--d("num addon calls", count)
				--d(msg)
				if count ~= 3 then
					ZO_ERROR_FRAME:OnUIError(msg)
				--	self:Debug("FurniturePreview error. No valid hook")
					return
				end
				
				lib.validHook = true
				
				EVENT_MANAGER.RegisterForUpdate = lib.origRegisterForUpdate
				ZO_ItemPreview_Shared.OnPreviewShowing = function(...)
					lib.origOnPreviewShowing(...)
					EVENT_MANAGER:UnregisterForUpdate(name)
					EVENT_MANAGER:RegisterForUpdate(name, 0, func)
				end
			end
		end)--
		zo_callLater(function()
			local fragment = SYSTEMS:GetObject("itemPreview").fragment
			fragment:SetHideOnSceneHidden(false)
			HUD_SCENE:RemoveFragment(fragment)
			fragment:SetHideOnSceneHidden(true)
		end, 0)
	end)

	lib.hookedTypes = {
		[ZO_ITEM_PREVIEW_FURNITURE_MARKET_PRODUCT] = true,
		[ZO_ITEM_PREVIEW_MARKET_PRODUCT] = true,
	}
	
	lib.origSharedPreviewSetup = ZO_ItemPreview_Shared.SharedPreviewSetup
--[[--removed Aug16 to try to disable armor preview
	lib.origIsCharacterPreviewingAvailable = IsCharacterPreviewingAvailable
	ZO_PreHook("IsCharacterPreviewingAvailable", function()
		if previewStarted then
			previewStarted = false
			
			if IsInGamepadPreferredMode() then
				ITEM_PREVIEW_GAMEPAD.previewAtMS = GetFrameTimeMilliseconds()
			else
				ITEM_PREVIEW_KEYBOARD.previewAtMS = GetFrameTimeMilliseconds()-- + ITEM_PREVIEW_KEYBOARD.previewBufferMS
			end

			return true
		end
	end)--]]

end

lib:Load()
