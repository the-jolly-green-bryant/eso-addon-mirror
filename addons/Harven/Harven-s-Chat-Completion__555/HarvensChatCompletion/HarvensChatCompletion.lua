local HarvensChatCompletion = {}

function HarvensChatCompletion.PasteSelected(text)
	CHAT_SYSTEM:StartTextEntry(text)
end

function HarvensChatCompletion.TextChanged(control, newText)
	HarvensChatCompletion.orgChatTextEntryTextChanged(control, newText)
	
	if not HarvensChatCompletion.menuHidden then
		HarvensChatCompletion.menuHidden = true
		ClearMenu()
	end
	
	if not newText or newText == "" then
		return
	end
	
	if not string.match(newText, "^/%w+$") then
		return
	end
	
	ClearMenu()
	local pattern = newText.."%w+"
	local showMenu = false
	for k,v in pairs(SLASH_COMMANDS) do
		if string.match(k, pattern) then
			showMenu = true
			AddMenuItem(k, function() HarvensChatCompletion.PasteSelected(k) end)
		end
	end
	
	if showMenu then
		ShowMenu(control, 1)
		ZO_Menu:ClearAnchors()
		ZO_Menu:SetAnchor(BOTTOMLEFT, CHAT_SYSTEM.textEntry.editControl, TOPLEFT, 0, 0)
		HarvensChatCompletion.menuHidden = false
	end
end

function HarvensChatCompletion.UpArrowPressed(...)
	if HarvensChatCompletion.menuHidden or ZO_Menu_GetNumMenuItems() == 0 or not IsMenuVisisble() then
		HarvensChatCompletion.orgChatTextPreviousCommand(...)
		return
	end
	
	HarvensChatCompletion.selectedItem = ZO_Menu_GetNumMenuItems()
	ZO_Menu_SetSelectedIndex(HarvensChatCompletion.selectedItem)
	
	HarvensChatCompletion.hackEditBox:SetHidden(false)
	HarvensChatCompletion.hackEditBox:TakeFocus()
end

function HarvensChatCompletion.DownArrowPressed(...)
	if HarvensChatCompletion.menuHidden or ZO_Menu_GetNumMenuItems() == 0 or not IsMenuVisisble() then
		HarvensChatCompletion.orgChatTextNextCommand(...)
		return
	end
	
	HarvensChatCompletion.selectedItem = 1
	ZO_Menu_SetSelectedIndex(HarvensChatCompletion.selectedItem)
	
	HarvensChatCompletion.hackEditBox:SetHidden(false)
	HarvensChatCompletion.hackEditBox:TakeFocus()
end

--i think it's missing ;)
local function ZO_Menu_GetSelectedControl(selectedIndex)
    return ZO_Menu.items[selectedIndex].item
end

function HarvensChatCompletion.Initialize(eventType, addonName)
	if addonName ~= "HarvensChatCompletion" then
		return
	end
	
	HarvensChatCompletion.menuHidden = true
	HarvensChatCompletion.orgChatTextEntryTextChanged = ZO_ChatTextEntry_TextChanged
	ZO_ChatTextEntry_TextChanged = HarvensChatCompletion.TextChanged
	
	--this is ugly
	HarvensChatCompletion.orgChatTextNextCommand = ZO_ChatTextEntry_NextCommand
	ZO_ChatTextEntry_NextCommand = HarvensChatCompletion.DownArrowPressed
	HarvensChatCompletion.orgChatTextPreviousCommand = ZO_ChatTextEntry_PreviousCommand
	ZO_ChatTextEntry_PreviousCommand = HarvensChatCompletion.UpArrowPressed
	
	--and this is soooooo more than ugly :P
	HarvensChatCompletion.hackEditBox = WINDOW_MANAGER:CreateControlFromVirtual("HarvensChatCompletionHackEditBox", ZO_Menu, "ZO_DefaultEditForBackdrop")
	HarvensChatCompletion.hackEditBox:SetHidden(true)
	HarvensChatCompletion.hackEditBox:SetMaxInputChars(0)
	HarvensChatCompletion.hackEditBox:SetEditEnabled(false)
	HarvensChatCompletion.hackEditBox:SetColor(0,0,0,0)
	HarvensChatCompletion.hackEditBox:SetAlpha(0)
	HarvensChatCompletion.hackEditBox:SetHandler("OnUpArrow", function(...)
		HarvensChatCompletion.selectedItem = HarvensChatCompletion.selectedItem - 1
		if HarvensChatCompletion.selectedItem < 1 then
			HarvensChatCompletion.selectedItem = ZO_Menu_GetNumMenuItems()
		end
		ZO_Menu_SetSelectedIndex(HarvensChatCompletion.selectedItem)
	end)
	HarvensChatCompletion.hackEditBox:SetHandler("OnDownArrow", function(...)
		HarvensChatCompletion.selectedItem = HarvensChatCompletion.selectedItem + 1
		if HarvensChatCompletion.selectedItem > ZO_Menu_GetNumMenuItems() then
			HarvensChatCompletion.selectedItem = 1
		end
		ZO_Menu_SetSelectedIndex(HarvensChatCompletion.selectedItem)
	end)
	HarvensChatCompletion.hackEditBox:SetHandler("OnFocusLost", function(self)
		HarvensChatCompletion.menuHidden = true
		ClearMenu()
	end)
	HarvensChatCompletion.hackEditBox:SetHandler("OnEnter", function(self)
		ZO_Menu_ClickItem(ZO_Menu_GetSelectedControl(HarvensChatCompletion.selectedItem),1)
		self:LoseFocus()
		self:SetHidden(true)
	end)
end

EVENT_MANAGER:RegisterForEvent("HarvensChatCompletion", EVENT_ADD_ON_LOADED, HarvensChatCompletion.Initialize)
