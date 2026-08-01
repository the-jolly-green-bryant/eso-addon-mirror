-----------------------------------------
--                                     --
--            ChatMultiWindow          --
--                                     --
-----------------------------------------

local ChatMultiWindow = {
	["name"] = "ChatMultiWindow",
	["version"] = 1.8,
}

ChatMultiWindow.Default = {}
ChatMultiWindow.Default.Hide = {}


function ChatMultiWindow.OnFocusGained(self)
	for i=GetNumChatContainers(), 2, -1  do
		CHAT_SYSTEM.containers[i].fadeAnim:Stop()
		CHAT_SYSTEM.containers[i].fadeAnim.m_fadeTimeline:PlayBackward()
		for j=1, #CHAT_SYSTEM.containers[i].windows do
			CHAT_SYSTEM.containers[i].windows[j].buffer:SetLineFade(0, 0)
		end
	end	
end


function ChatMultiWindow.OnFocusLost(self)
	for i=GetNumChatContainers(), 2, -1  do
		CHAT_SYSTEM.containers[i].fadeAnim.m_fadeTimeline:PlayForward()
		for j=1, #CHAT_SYSTEM.containers[i].windows do
			CHAT_SYSTEM.containers[i].windows[j].buffer:SetLineFade(25, 2)
		end
	end
end


function ChatMultiWindow.FixContainerAnchor(container)
	container.windowContainer:ClearAnchors()
	container.windowContainer:SetAnchor(TOPRIGHT, container.scrollUpButton, TOPLEFT, 0, 0)
	container.windowContainer:SetAnchor(BOTTOMLEFT, container.windowContainer:GetParent(), BOTTOMLEFT, 20, -20)	 
end


function ChatMultiWindow.OnClickedLock(control)
	if ChatMultiWindow.locked == true then
		ChatMultiWindow.Lock:SetNormalTexture("/esoui/art/miscellaneous/unlocked_up.dds")
		ChatMultiWindow.Lock:SetPressedTexture("/esoui/art/miscellaneous/unlocked_down.dds")
		ChatMultiWindow.Lock:SetMouseOverTexture("/esoui/art/miscellaneous/unlocked_over.dds")
		CHAT_SYSTEM:SetAllowMultipleContainers(true)
		ChatMultiWindow.locked = false
	else
		ChatMultiWindow.Lock:SetNormalTexture("/esoui/art/miscellaneous/locked_up.dds")
		ChatMultiWindow.Lock:SetPressedTexture("/esoui/art/miscellaneous/locked_down.dds")
		ChatMultiWindow.Lock:SetMouseOverTexture("/esoui/art/miscellaneous/locked_over.dds")
		CHAT_SYSTEM:SetAllowMultipleContainers(false)
		ChatMultiWindow.locked = true
	end
end


function ChatMultiWindow.OnClickedHide(control)
	ChatMultiWindow.SavedVars.Hide[control.containerId] = not ChatMultiWindow.SavedVars.Hide[control.containerId]
	if ChatMultiWindow.SavedVars.Hide[control.containerId] == true then
		control:SetNormalTexture("/esoui/art/inventory/inventory_tabicon_misc_up.dds")
		if ZO_MainMenuCategoryBar:IsHidden() == false then
			CHAT_SYSTEM.containers[control.containerId].control:SetHidden(true)
		end
	else
		control:SetNormalTexture("/esoui/art/inventory/inventory_tabicon_misc_down.dds")
	end
end


function ChatMultiWindow.OnShowMainMenu()
	for i=GetNumChatContainers(), 2, -1  do
		if ChatMultiWindow.SavedVars.Hide[i] then
			CHAT_SYSTEM.containers[i].control:SetHidden(true)
		end
	end
end


function ChatMultiWindow.OnHideMainMenu()
	for i=GetNumChatContainers(), 2, -1  do
		CHAT_SYSTEM.containers[i].control:SetHidden(false)
	end
end


function ChatMultiWindow.OnPlayerActivated()
	local control, name, anchortarget

	if ChatMultiWindow.Lock == nil then
		-- Destroy emppty containers
		ChatMultiWindow.FixEmptyContainers()

		-- Fix any windows that were loaded on startup
		for i=2, #CHAT_SYSTEM.containers do
			--disable debug messages for additional containers
			ZO_PreHook(CHAT_SYSTEM.containers[i], "AddDebugMessage", function() return true end)
			ChatMultiWindow.FixContainerAnchor(CHAT_SYSTEM.containers[i])
			control = WINDOW_MANAGER:CreateControl("ChatMultiWindowHide" ..i, CHAT_SYSTEM.containers[i].control, CT_BUTTON)
			control.containerId = i
			if ChatMultiWindow.SavedVars.Hide[control.containerId] == nil then
				ChatMultiWindow.SavedVars.Hide[control.containerId] = true
			end			
			control:SetDimensions(24, 24)
			name = string.format("ZO_ChatContainerTemplate%dOptions", i - 1)
			anchortarget = _G[name]			
			control:SetAnchor(RIGHT, anchortarget, LEFT, -8, 0)
			if ChatMultiWindow.SavedVars.Hide[i] == true then
				control:SetNormalTexture("/esoui/art/inventory/inventory_tabicon_misc_up.dds")
			else
				control:SetNormalTexture("/esoui/art/inventory/inventory_tabicon_misc_down.dds")
			end			
			control:SetMouseOverTexture("/esoui/art/inventory/inventory_tabicon_misc_over.dds")
			control:SetHandler("OnClicked", ChatMultiWindow.OnClickedHide)
			control:SetHidden(false)
		end

		ChatMultiWindow.Lock = WINDOW_MANAGER:CreateControl("ChatMultiWindowLock", ZO_ChatWindow, CT_BUTTON)
		ChatMultiWindow.Lock:SetDimensions(16, 16)
		ChatMultiWindow.Lock:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, -8, 0)
		ChatMultiWindow.Lock:SetNormalTexture("/esoui/art/miscellaneous/locked_up.dds")
		ChatMultiWindow.Lock:SetPressedTexture("/esoui/art/miscellaneous/locked_down.dds")
		ChatMultiWindow.Lock:SetMouseOverTexture("/esoui/art/miscellaneous/locked_over.dds")
		ChatMultiWindow.Lock:SetHandler("OnClicked", ChatMultiWindow.OnClickedLock)
		ChatMultiWindow.Lock:SetHidden(false)

		ZO_ChatWindowTextEntryEditBox:SetHandler("OnFocusGained", 	ChatMultiWindow.OnFocusGained)
		ZO_ChatWindowTextEntryEditBox:SetHandler("OnFocusLost", 	ChatMultiWindow.OnFocusLost)
		ZO_MainMenuCategoryBar:SetHandler("OnEffectivelyShown", 	ChatMultiWindow.OnShowMainMenu)
		ZO_MainMenuCategoryBar:SetHandler("OnEffectivelyHidden",	ChatMultiWindow.OnHideMainMenu)
	end
	
	CHAT_SYSTEM:SetAllowMultipleContainers(false)
	ChatMultiWindow.locked = true
end


function ChatMultiWindow.FixEmptyContainers()
	if GetNumChatContainers() > 1 then
		for i=GetNumChatContainers(), 2, -1  do
			local numContainerTabs = GetNumChatContainerTabs(i)		  
			if numContainerTabs == 0 then
				CHAT_SYSTEM:DestroyContainer(CHAT_SYSTEM.containers[i])		  
			end
		end
	end
end


function ChatMultiWindow.OnPlayerDeactivated()
	CHAT_SYSTEM:SetAllowMultipleContainers(true)
	ChatMultiWindow.locked = false
end


function ChatMultiWindow.AddonLoaded(event, name)
	if name ~= "ChatMultiWindow" then
		return
	end
	CHAT_SYSTEM:SetAllowMultipleContainers(true)

	ChatMultiWindow.SavedVars = ZO_SavedVars:New(ChatMultiWindow.name.."_SavedVariables", 1, nil, ChatMultiWindow.Default)

	EVENT_MANAGER:RegisterForEvent(ChatMultiWindow.name, EVENT_PLAYER_DEACTIVATED,	ChatMultiWindow.OnPlayerDeactivated)
	EVENT_MANAGER:RegisterForEvent(ChatMultiWindow.name, EVENT_PLAYER_ACTIVATED,		ChatMultiWindow.OnPlayerActivated)    
	EVENT_MANAGER:UnregisterForEvent(ChatMultiWindow.name, EVENT_ADD_ON_LOADED)
end

-- Register addon
EVENT_MANAGER:RegisterForEvent(ChatMultiWindow.name, EVENT_ADD_ON_LOADED, ChatMultiWindow.AddonLoaded)

-- Hook the original function so we can fix the anchors
local TransferWindow = CHAT_SYSTEM.TransferWindow
function CHAT_SYSTEM.TransferWindow(self, window, previousContainer, targetContainer)
	local container = targetContainer or self:CreateChatContainer()

	TransferWindow(self, window, previousContainer, container)

	if container ~= CHAT_SYSTEM.containers[1] then
		ChatMultiWindow.FixContainerAnchor(container)
	end
end
