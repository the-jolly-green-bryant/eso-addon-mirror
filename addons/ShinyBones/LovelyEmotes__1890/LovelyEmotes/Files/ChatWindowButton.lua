LE_ChatWindowButton = ZO_Object:New()

function LE_ChatWindowButton:Initialize()
	self.Control = WINDOW_MANAGER:CreateControl(nil, ZO_ChatWindow, CT_BUTTON)
	self.Control:SetDimensions(32, 32)

	self.Control:SetNormalTexture("esoui/art/icons/emotes/keyboard/emotecategoryicon_entertain_up.dds")
	self.Control:SetMouseOverTexture("esoui/art/icons/emotes/keyboard/emotecategoryicon_entertain_over.dds")
	self.Control:SetPressedTexture("esoui/art/icons/emotes/keyboard/emotecategoryicon_entertain_down.dds")

	self.Control:SetHandler("OnClicked", function(control, button) LovelyEmotes.MainWindow.ToggleMinimized() end)

	self:SetHidden(not LovelyEmotes_Settings.SavedAccountVariables.EnableChatWindowButton)
    self:SetPosition(LovelyEmotes_Settings.SavedAccountVariables.ChatWindowButtonPositionX)
end

function LE_ChatWindowButton:SetHidden(value)
	LovelyEmotes_Settings.SavedAccountVariables.EnableChatWindowButton = not value

	self.Control:SetHidden(value)
end

function LE_ChatWindowButton:SetPosition(x)
	LovelyEmotes_Settings.SavedAccountVariables.ChatWindowButtonPositionX = x

	self.Control:ClearAnchors()
	self.Control:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, (45 + x) * -1, 7)
end
