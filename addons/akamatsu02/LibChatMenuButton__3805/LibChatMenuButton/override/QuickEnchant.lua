QuickEnchantOverrideButton = {}
QuickEnchantOverrideButton.__index = QuickEnchantOverrideButton

local function override()
	if not QE_Window then return end
	if not QE_Window.chatbutton then return end

	local button = LibChatMenuButton.addChatButton("QuickEnchanterLCMB", "esoui/art/icons/servicemappins/servicepin_enchanting.dds", QE_Language[QuickEnchanter.savedVars.language].show_button_text, function() 
		QE_Window:HideMainWindow(not QE_Window_Screen:IsHidden()) 
	end)
	if QuickEnchanter.savedVars.hide_chat_button and true or false then
		button:hide()
	else
		button:show()
	end
	QE_Window.chatbutton:SetHidden(true)
	QE_Window.chatbutton = {}
	setmetatable(QE_Window.chatbutton, QuickEnchantOverrideButton)
	QE_Window.chatbutton.button = button
end

function QuickEnchantOverrideButton.SetHidden(self, bool)
	if bool then
		self.button:hide()
	else
		self.button:show()
	end
end

function QuickEnchantOverrideButton.SetAnchor(self, text)
	
end

table.insert(LibChatMenuButton.override, override)