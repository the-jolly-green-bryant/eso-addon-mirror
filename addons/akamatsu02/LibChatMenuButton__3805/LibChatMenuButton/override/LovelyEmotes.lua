LovelyEmotesOverrideButton = {}
LovelyEmotesOverrideButton.__index = LovelyEmotesOverrideButton

local function override()
	if not LovelyEmotes then return end
	if not LovelyEmotes_Settings then LovelyEmotes_Settings = LovelyEmotes end
	if not LE_ChatWindowButton then return end

	local button = LibChatMenuButton.addChatButton("LEChatWindowButtonLCMB", {"esoui/art/icons/emotes/keyboard/emotecategoryicon_entertain_up.dds", "esoui/art/icons/emotes/keyboard/emotecategoryicon_entertain_over.dds", "esoui/art/icons/emotes/keyboard/emotecategoryicon_entertain_down.dds"}, "LovelyEmotes", function(control, button) LovelyEmotes.MainWindow.ToggleMinimized() end)
	if not LovelyEmotes_Settings.SavedAccountVariables.EnableChatWindowButton then
		button:hide()
	end
	LE_ChatWindowButton.Control:SetHidden(true)
	LE_ChatWindowButton = {}
	setmetatable(LE_ChatWindowButton, LovelyEmotesOverrideButton)
	LE_ChatWindowButton.button = button
end

function LovelyEmotesOverrideButton.SetHidden(self, bool)
	LovelyEmotes_Settings.SavedAccountVariables.EnableChatWindowButton = not bool
	if bool then
		self.button:hide()
	else
		self.button:show()
	end
end

function LovelyEmotesOverrideButton.SetPosition(self, x) end

table.insert(LibChatMenuButton.override, override)